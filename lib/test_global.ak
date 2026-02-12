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
  #"29d02c9f38c096197263ad0b865c329d076b8949ff634e9f8f9aacfbb50b956971337375a15ce3bfba3efca8eea8c27e70f35642e6c749191b9e28146b720916"

// UTxO to spend: a0ac0f4d492b4efcdb9e410f409e32708b21d11cb7edc4f7d1405d730f3a738d#0
const test_utxo =
  OutputReference(
    #"d9c9f2cd1afc1201696af4a2ae1a3c581d9ca9172cf63b25ebef329743435750",
    0,
  )

// Outputs hash from spend-global.ts
const test_outputs_hash =
  #"25cbad9d3d490bd31b835984beb4c3cef67618a05d05851742df2aa81ee5cc37"

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
        1,
        1,
        #"48e0848a0b401e4255fae381091ec9f6a68424de5c17ea2451de2c3d",
        #"48e0848a0b401e4255fae381091ec9f6a68424de5c17ea2451de2c3d",
      ),
      from_lovelace(96000000),
      NoDatum,
      None,
    )

  // Show the hash that this output produces
  let outputs = [output, output2]
  let serialized = cbor.serialise(list.slice(outputs, 0, 1))
  trace cbor.diagnostic(serialized)
  let calculated_hash = hash(serialized)

  trace @"Calculated outputs hash with structured datum:"
  trace cbor.diagnostic(calculated_hash)
  trace @"Expected outputs hash:"
  trace cbor.diagnostic(test_outputs_hash)

  let flag_outputs = all_outputs_present(test_outputs_hash, 1, outputs)

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
