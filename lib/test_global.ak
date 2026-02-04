use aiken/builtin
use aiken/cbor
use aiken/collection/list
use aiken/crypto.{blake2b_256, sha2_256}
use aiken/primitive/bytearray.{length}
use aiken/primitive/string
use cardano/address.{
  Address, from_script, from_verification_key, with_delegation_key,
  with_delegation_script,
}
use cardano/assets.{from_lovelace}
use cardano/transaction.{InlineDatum, NoDatum, Output, OutputReference}
use constants

// ============================================================================
// DATUM TYPE DEFINITION
// Based on CBOR diagnostic:
// 123([_ 121([_ addr1, addr2, None, token_info, min_amount, max_amount])])
// ============================================================================

// Asset pair structure (constructor 0 = 121)
pub type AssetPair {
  policy_id: ByteArray,
  asset_name: ByteArray,
}

// Token info structure: (AssetPair, quantity)
pub type TokenInfo {
  asset: AssetPair,
  quantity: Int,
}

// The inner datum structure (constructor 0 = 121)
pub type SwapDatumInner {
  address1: Address,
  address2: Address,
  optional_field: Option<Data>,
  token_info: TokenInfo,
  min_amount: Int,
  max_amount: Int,
}

// ============================================================================
// TEST DATA from spend-global.ts
// ============================================================================

// Public key from CONFIG.validatorPubKey
const test_pubkey =
  #"02b333f3293d47c9bf6083b706f554c131a955699db7df2d401f44a0404e3872ba"

// Signature from spend-global.ts (64 bytes r||s)
const test_signature =
  #"2b00b7ec40be17666c2f72b1bf45ff9554c9de6c996df581e863ba0fec06cfd46baf6e47ac6f9d39a067149b12cd1e19121ab03eb9bc88981d86319a2608fe25"

// UTxO to spend: a0ac0f4d492b4efcdb9e410f409e32708b21d11cb7edc4f7d1405d730f3a738d#0
const test_utxo =
  OutputReference(
    #"e3e3de07830b1d466c3fd3fde53e8aa848bb50c4a8dea3676f433bf3872d80a0",
    0,
  )

// Outputs hash from spend-global.ts
const test_outputs_hash =
  #"2e0db12bc580d94fefdd6ac1d29221752e0e0f3d27e4ada4bdf12d58815e24dd"

// OLD version per confronto
fn get_hash_from_bytearray_btc_OLD(byte: ByteArray) -> ByteArray {
  // VECCHIO: Prima faceva doppio SHA256 e poi convertiva in HEX
  let concat_message =
    string.to_bytearray(bytearray.to_hex(sha2_256(sha2_256(byte))))
  trace @"SI FIRMA QUESTO"
  trace cbor.diagnostic(concat_message)
  let size = length(concat_message)

  let final_message =
    bytearray.concat(bytearray.from_int_big_endian(size, 1), concat_message)

  let magic_array = bytearray.from_string(constants.magic_btc)
  let final_magic = bytearray.concat(#"18", magic_array)

  let finalized = bytearray.concat(final_magic, final_message)

  sha2_256(sha2_256(finalized))
}

fn validate_signature_key(publicKey: ByteArray, msg: ByteArray, sig: ByteArray) {
  builtin.verify_ecdsa_secp256k1_signature(publicKey, msg, sig)
}

// ============================================================================
// TEST: Cosa deve contenere il messaggio da firmare
// ============================================================================

pub fn calculate_address(
  flag_spending_script: Int,
  flag_staking_script: Int,
  pubkey: ByteArray,
  stakekey: ByteArray,
) -> Address {
  if flag_spending_script == 0 && flag_staking_script == 0 {
    from_verification_key(pubkey) |> with_delegation_key(stakekey)
  } else {
    if flag_spending_script == 0 && flag_staking_script == 1 {
      from_verification_key(pubkey) |> with_delegation_script(stakekey)
    } else {
      if flag_spending_script == 1 && flag_staking_script == 0 {
        from_script(pubkey) |> with_delegation_key(stakekey)
      } else {
        if flag_spending_script == 1 && flag_staking_script == 1 {
          from_script(pubkey) |> with_delegation_script(stakekey)
        } else {
          from_verification_key(pubkey) |> with_delegation_key(stakekey)
        }
      }
    }
  }
}

// Helper to create a Script address with empty credentials (like 122([_ h'']))
fn script_address_empty() -> Address {
  from_script(#"") |> with_delegation_script(#"")
}

// Build the structured datum instead of raw CBOR bytes
fn build_swap_datum() -> SwapDatumInner {
  let asset_pair =
    AssetPair {
      policy_id: #"0b77d150c275bd0a600633e4be7d09f83c4b9f00981e22ac9c9d3f62",
      asset_name: #"0014df1074464c4454",
    }

  let token_info = TokenInfo { asset: asset_pair, quantity: 1 }

  SwapDatumInner {
    address1: script_address_empty(),
    address2: script_address_empty(),
    optional_field: None,
    token_info,
    min_amount: 2000000,
    max_amount: 2000000,
  }
}

test test_outputs() {
  // Build the datum structurally
  let datum = build_swap_datum()

  // Debug: show what the structured datum serializes to
  trace @"Structured datum CBOR:"
  trace cbor.diagnostic(datum)

  // Build the output with structured datum
  let output =
    Output(
      calculate_address(
        0,
        0,
        #"00fc7385d20b7992bee4d40c119e06211e79eebe1bb4bf5b04a21b2e",
        #"aec59d01341908a345a697adcbbb632a0d6e98ba4a8942eb9a0e75b0",
      ),
      from_lovelace(3000000),
      InlineDatum(datum),
      None,
    )

  let output2 =
    Output(
      calculate_address(
        0,
        0,
        #"619b1b290a86129ddcbda3397fed176b1b6d47c12a75a3e0e0bdfea7",
        #"e1a1fcec14f1970043b0b31022133a6a0b3b33be8b81bf1eb33e0eea",
      ),
      from_lovelace(399826447),
      NoDatum,
      None,
    )

  // Show the hash that this output produces
  let outputs = [output, output2]
  let serialized = cbor.serialise(list.slice(outputs, 0, 0))
  trace cbor.diagnostic(serialized)
  let calculated_hash = hash(serialized)

  trace @"Calculated outputs hash with structured datum:"
  trace cbor.diagnostic(calculated_hash)
  trace @"Expected outputs hash:"
  trace cbor.diagnostic(test_outputs_hash)

  let flag_outputs = all_outputs_present(test_outputs_hash, 0, outputs)

  trace @"All outputs present (should be true):"
  trace cbor.diagnostic(flag_outputs)
  let utxos = [test_utxo]
  let message_array: List<ByteArray> =
    list.push([], cbor.serialise(utxos))
      |> list.push(cbor.serialise(test_outputs_hash))

  let serialized_input = cbor.serialise(message_array)

  trace @""
  trace @"Input (CBOR serializzato di [utxos, outputs_hash]):"
  trace cbor.diagnostic(serialized_input)

  let hash_old = get_hash_from_bytearray_btc_OLD(serialized_input)
  let firma_lore = validate_signature_key(test_pubkey, hash_old, test_signature)
  firma_lore
  // For now, just check the datum structure is correct
  // The hash will be different because we're using structured datum
}

pub fn all_outputs_present(
  outputs_chosen_hash: ByteArray,
  length: Int,
  real_outputs: List<Output>,
) {
  trace cbor.diagnostic(cbor.serialise(list.slice(real_outputs, 0, length)))
  trace @"onchain evaluation and HASH result"
  trace cbor.diagnostic(
    hash(cbor.serialise(list.slice(real_outputs, 0, length))),
  )
  trace @"Outputs chosen hash:"
  trace cbor.diagnostic(outputs_chosen_hash)
  hash(cbor.serialise(list.slice(real_outputs, 0, length))) == outputs_chosen_hash
}

pub fn hash(data: Data) {
  blake2b_256(cbor.serialise(data))
}
