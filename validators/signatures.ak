use aiken/builtin
use aiken/cbor
use aiken/collection/list
use aiken/crypto.{keccak_256, sha2_256}
use aiken/primitive/bytearray.{length}
use aiken/primitive/int.{to_string}
use aiken/primitive/string
use cardano/transaction.{OutputReference}

pub type Redeemer {
  signature: ByteArray,
  utxo: OutputReference,
  policy: ByteArray,
  assetname: ByteArray,
  amount: Int,
  pubkey: ByteArray,
  stakekey: ByteArray,
}

pub type RedeemerStake {
  signature: ByteArray,
  deadline: Int,
}

fn generate_redeemer_string_evm(
  redeemer: RedeemerStake,
  poolId: ByteArray,
) -> String {
  let message_array: List<ByteArray> =
    list.push([], poolId)
      |> list.push(bytearray.from_int_big_endian(redeemer.deadline, 20))

  //trace cbor.diagnostic(sha2_256(sha2_256(concat_array(message_array))))
  bytearray.to_hex(sha2_256(sha2_256(concat_array(message_array))))
}

// fn generate_redeemer_array(redeemer: Redeemer) -> ByteArray {
//   let message_array: List<ByteArray> =
//     list.push([], redeemer.stakekey)
//       |> list.push(redeemer.pubkey)
//       |> list.push(bytearray.from_int_big_endian(redeemer.amount, 20))
//       |> list.push(redeemer.assetname)
//       |> list.push(redeemer.policy)
//       |> list.push(bytearray.from_int_big_endian(redeemer.utxo.output_index, 1))
//       |> list.push(redeemer.utxo.transaction_id)
//   concat_array(message_array)
// }

fn concat_array(list_array: List<ByteArray>) {
  list.reduce(list_array, #[], bytearray.concat)
}

const magic =
  @"Bitcoin Signed Message:\n"

fn generate_message_hash(message: String) -> ByteArray {
  let bytes = string.to_bytearray(message)
  let size = length(bytes)

  let final_message =
    bytearray.concat(bytearray.from_int_big_endian(size, 1), bytes)
  let final_magic = bytearray.concat(#"18", bytearray.from_string(magic))

  let finalized = bytearray.concat(final_magic, final_message)

  let message_hash = sha2_256(sha2_256(finalized))
  message_hash
}

// const magic_doge =
//   @"Dogecoin Signed Message:\n"

// fn generate_message_hash_doge(message: String) -> ByteArray {
//   let bytes = string.to_bytearray(message)
//   let size = length(bytes)

//   let final_message =
//     bytearray.concat(bytearray.from_int_big_endian(size, 1), bytes)
//   let final_magic = bytearray.concat(#"19", bytearray.from_string(magic_doge))

//   let finalized = bytearray.concat(final_magic, final_message)

//   let message_hash = sha2_256(sha2_256(finalized))
//   message_hash
// }

const magicevm =
  @"Ethereum Signed Message:\n"

fn generate_message_hash_evm(message: String) -> ByteArray {
  let bytes = string.to_bytearray(message)
  let size = string.to_bytearray(to_string(length(bytes)))

  let final_message = bytearray.concat(size, bytes)
  let final_magic = bytearray.concat(#"19", bytearray.from_string(magicevm))

  let finalized = bytearray.concat(final_magic, final_message)
  //trace cbor.diagnostic(finalized)
  let message_hash = keccak_256(finalized)
  message_hash
}

const signature =
  #"8750b5e1e7b2a42e13e73b11b771b9cc3496eee7c6f6c0f1041350d5345f93f0171b737488d1c505a03910a032227bf520e15eb5af7e0b69f81cf41e3aaabd49"

const pubkey =
  #"028fa6b017c4ca1b794c2f5eb6413c3bf2537689c026d75a192a26a01ff86d04b3"

//a57805e57fccecb921cf9acac130b9ca8f76f73fc21ff5c7d04b76849424806e1ee52ad1ef3c5721a9e5ced31ef66afe7e586c8d76349558b20e01f913fb4a8e1c
const signaturevm =
  #"5907ff919d4d3d901ae4a9a0ab3d43228043e2c9e66b419f95441e82b2fc320c1c2111ca8a0a7c46c5d1b6dc2b4cf672fcf493f2cafefe8819a8b678c1636e7d"

const pubkeyevm =
  #"03d60f06fdfc20cde4cabf176237101424b141ba2fae5fb621717d4192f292c0a2"

const messagevm =
  @"BB1354D7A4AD7EB7A82C1A77A8CFBAA8F0F0F7133919FF253A5301309E943876"

const messagebtc = @"hello"

test signature_litecoin() {
  let messageHash = generate_message_hash(messagebtc)
  validate_signature_key(pubkey, messageHash, signature) == True
}

test signature_evm() {
  let messageHash = generate_message_hash_evm(messagevm)
  validate_signature_key(pubkeyevm, messageHash, signaturevm) == True
}

fn validate_signature_key(publicKey: ByteArray, msg: ByteArray, sig: ByteArray) {
  builtin.verify_ecdsa_secp256k1_signature(publicKey, msg, sig)
}

const test_redeemer_publish =
  RedeemerStake(
    #"d8db455cab38de6160a738e9b2d72b0814dfd4ec27899025821b82881fc936a7777fae2e11f689a8133968e29f04a2931e3e230fc53afce691141fed5768eefe",
    1734696439051,
  )

test redeemer_string_evm() {
  generate_redeemer_string_evm(
    test_redeemer_publish,
    #"06a9d41c3d9bba41740986a59f484a23967329f1513bc982974aa8bf",
  ) == @"17A587B802ED0368609D20D1CBB4DC32B18982DF6FB27711D3201ED4BEFA32D6"
}

pub type RedeemerReal {
  signature: ByteArray,
  utxos: List<OutputReference>,
  policy: ByteArray,
  assetname: ByteArray,
  amount: Int,
  policyInput: ByteArray,
  assetnameInput: ByteArray,
  amountInput: Int,
  spendingscriptflag: Int,
  pubkey: ByteArray,
  stakingscriptflag: Int,
  stakekey: ByteArray,
  datumflag: Int,
  datum: Data,
  payment_index: Int,
  fee: Int,
}

const test_redeemer_real =
  RedeemerReal(
    #"a251899902749ac4919a1ebb6f093872f7bd902ffec4a1efe622061b1deb7ab67d4dc017e3fcbfe2bfda5104730130c88ca240f57ca42552ccd893bf1226b662",
    [
      OutputReference(
        #"39ac37115ea67f43a80ec39780157b5df6ceacd69aa2ac81846a2f124a7665db",
        0,
      ),
      OutputReference(
        #"63b44cc17276a9e9fe22ef8b36a4b79fa668d4b4214d501fa01c442e47cc1df7",
        0,
      ),
    ],
    #"",
    #"",
    12000000,
    #"",
    #"",
    0,
    0,
    #"e597eee23b8d269e4df5f7eab90dec9924bc4b813814ca17270bc57b",
    0,
    #"91da02fd4bf9e6ccbbc621b204de5d1bcaa40d399f9ec3fe4790cb45",
    0,
    "",
    0,
    1000000,
  )

fn generate_redeemer_string_real(redeemer: RedeemerReal) -> String {
  let list_utxos =
    list.foldr(
      redeemer.utxos,
      [],
      fn(utxo, xs) {
        [
          utxo.transaction_id,
          bytearray.from_int_big_endian(utxo.output_index, 1),
          ..xs
        ]
      },
    )
  expect datum_converted: ByteArray = redeemer.datum
  let message_array: List<ByteArray> =
    list.push([], bytearray.from_int_big_endian(redeemer.fee, 20))
      |> list.push(bytearray.from_int_big_endian(redeemer.payment_index, 1))
      |> list.push(datum_converted)
      |> list.push(bytearray.from_int_big_endian(redeemer.datumflag, 1))
      |> list.push(redeemer.stakekey)
      |> list.push(bytearray.from_int_big_endian(redeemer.stakingscriptflag, 1))
      |> list.push(redeemer.pubkey)
      |> list.push(bytearray.from_int_big_endian(redeemer.spendingscriptflag, 1))
      |> list.push(bytearray.from_int_big_endian(redeemer.amountInput, 20))
      |> list.push(redeemer.assetnameInput)
      |> list.push(redeemer.policyInput)
      |> list.push(bytearray.from_int_big_endian(redeemer.amount, 20))
      |> list.push(redeemer.assetname)
      |> list.push(redeemer.policy)

  //trace cbor.diagnostic(concat_array(list.concat(list_utxos, message_array)))
  bytearray.to_hex(
    sha2_256(sha2_256(concat_array(list.concat(list_utxos, message_array)))),
  )
}

test sending_assets_validation() {
  generate_redeemer_string_real(test_redeemer_real) == @"F10D57058072065AB13AF839A31E97C18EC7094C5A5E33E9A99110FB1AE92B54"
}
