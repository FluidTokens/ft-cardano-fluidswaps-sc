use aiken/builtin
use aiken/cbor
use aiken/collection/list
use aiken/crypto.{blake2b_256, keccak_256, sha2_256}
use aiken/primitive/bytearray.{length}
use aiken/primitive/int.{to_string}
use aiken/primitive/string
use cardano/address.{
  Address, Credential, Script, from_script, from_verification_key,
  with_delegation_key, with_delegation_script,
}
use cardano/assets.{Value, from_asset, from_lovelace, merge}
use cardano/transaction.{InlineDatum, NoDatum, Output, OutputReference}
use constants

fn concat_array(list_array: List<ByteArray>) {
  list.reduce(list_array, #[], bytearray.concat)
}

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

const output_one =
  Output(
    calculate_address(
      0,
      0,
      #"9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e",
      #"32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc",
    ),
    from_lovelace(2000000),
    NoDatum,
    None,
  )

const output_two =
  Output(
    calculate_address(
      0,
      0,
      #"9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e",
      #"32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc",
    ),
    merge(
      from_lovelace(5000000),
      from_asset(
        #"01010101010101010101010101010101010101010101010101010101",
        #"4d79546f6b656e",
        100,
      ),
    ),
    NoDatum,
    None,
  )

pub type BigDatum {
  name: ByteArray,
  age: Int,
  scores: List<Int>,
  address: Address,
}

const output_three =
  Output(
    calculate_address(
      0,
      0,
      #"9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e",
      #"32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc",
    ),
    from_lovelace(3000000),
    InlineDatum(
      BigDatum(
        #"4a6f686e20446f65",
        30,
        [85, 90, 95],
        calculate_address(
          0,
          0,
          #"9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e",
          #"32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc",
        ),
      ),
    ),
    None,
  )

const input_1 =
  OutputReference(
    #"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    0,
  )

const input_2 =
  OutputReference(
    #"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    1,
  )

pub fn hash(data: Data) {
  trace @"dentro hash"
  trace cbor.diagnostic(data)
  trace cbor.diagnostic(cbor.serialise(data))
  blake2b_256(cbor.serialise(data))
}

test hash_output_one() {
  trace cbor.diagnostic(cbor.serialise(output_one))
  trace cbor.diagnostic(hash(cbor.serialise(output_one)))
  True
}

test hash_output_two() {
  trace cbor.diagnostic(cbor.serialise(output_two))
  trace cbor.diagnostic(hash(cbor.serialise(output_two)))
  True
}

test hash_output_three() {
  trace @"datum"
  trace cbor.diagnostic(
    cbor.serialise(
      BigDatum(
        #"4a6f686e20446f65",
        30,
        [85, 90, 95],
        calculate_address(
          0,
          0,
          #"9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e",
          #"32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc",
        ),
      ),
    ),
  )
  trace cbor.diagnostic(cbor.serialise(output_three))
  trace cbor.diagnostic(hash(cbor.serialise(output_three)))
  True
}

test list_hashes() {
  let outputs = [output_one, output_two, output_three]
  let serialized = cbor.serialise(list.slice(outputs, 0, 3))
  trace cbor.diagnostic(serialized)
  trace @"hashe outputs"
  trace cbor.diagnostic(hash(serialized))
  True
}

test hash_everything() {
  let outputs = [output_one, output_two, output_three]
  let inputs = [input_1, input_2]
  trace cbor.diagnostic(cbor.serialise(inputs))

  let serialized = cbor.serialise(list.slice(outputs, 0, 3))
  let outputs_hash = hash(serialized)
  let message_array: List<ByteArray> =
    list.push([], cbor.serialise(inputs))
      |> list.push(cbor.serialise(outputs_hash))
  trace cbor.diagnostic(concat_array(message_array))
  True
}

test messages_to_sign() {
  let outputs = [output_one, output_two, output_three]
  let inputs = [input_1, input_2]

  let serialized = cbor.serialise(list.slice(outputs, 0, 3))
  let outputs_hash = hash(serialized)
  let message_array: List<ByteArray> =
    list.push([], cbor.serialise(inputs))
      |> list.push(cbor.serialise(outputs_hash))

  trace cbor.diagnostic(concat_array(message_array))

  trace @"reserializzo"
  trace cbor.diagnostic(cbor.serialise(concat_array(message_array)))

  trace @"hash btc"
  trace cbor.diagnostic(
    get_hash_from_bytearray_btc(cbor.serialise(concat_array(message_array))),
  )
  trace @"hash eth"
  trace cbor.diagnostic(
    get_hash_from_bytearray_eth(cbor.serialise(concat_array(message_array))),
  )
  True
}

fn get_hash_from_bytearray_btc(byte: ByteArray) {
  //this is what I sign
  let concat_message =
    string.to_bytearray(bytearray.to_hex(sha2_256(sha2_256(byte))))
  let size = length(concat_message)

  //il doppio sha poi lo rendo stringa e maiuscolo, è quello che firmo
  let final_message =
    bytearray.concat(bytearray.from_int_big_endian(size, 1), concat_message)
  trace @"final message btc"
  trace cbor.diagnostic(final_message)
  let magic_array = bytearray.from_string(constants.magic_btc)
  let final_magic = bytearray.concat(#"18", magic_array)

  let finalized = bytearray.concat(final_magic, final_message)
  trace @"finalized btc"
  trace cbor.diagnostic(finalized)
  sha2_256(sha2_256(finalized))
}

fn get_hash_from_bytearray_eth(byte: ByteArray) {
  //this is what I sign
  let concat_message =
    string.to_bytearray(bytearray.to_hex(sha2_256(sha2_256(byte))))
  let size = string.to_bytearray(to_string(length(concat_message)))

  //il doppio sha poi lo rendo stringa e maiuscolo, è quello che firmo
  let final_message = bytearray.concat(size, concat_message)

  let magic_array = bytearray.from_string(constants.magic_eth)
  let final_magic = bytearray.concat(#"19", magic_array)

  let finalized = bytearray.concat(final_magic, final_message)

  keccak_256(finalized)
}
