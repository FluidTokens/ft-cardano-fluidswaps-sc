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

fn generate_message_hash_test(message: String) -> ByteArray {
  let bytes = string.to_bytearray(message)

  let message_hash = sha2_256(sha2_256(bytes))
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
  #"34f8d9084aa42e040a2c05177cd368c14ca14e6c2623193d322e5c1dfed7b4e841736d5c22f0a80e5b44f664c3c10672fb0ce2f9f9d8799cfc924f36826ceded"

const pubkey =
  #"03a84b5bdfb6b4e85fc1bfa2fa8fce292acc0119fd186132aba570b07564f28b5a"

//a57805e57fccecb921cf9acac130b9ca8f76f73fc21ff5c7d04b76849424806e1ee52ad1ef3c5721a9e5ced31ef66afe7e586c8d76349558b20e01f913fb4a8e1c
const signaturevm =
  #"caa0af53587df88bef82ff2afd11f626eefca2d4e1ccc326e735862c654112144d1dc6b7cdc47b3c0f846fd117ac825338cc222cd4d8ad83553f889eb4266241"

const pubkeyevm =
  #"026ce2fee81a8ddf0fd677f0ebd894d1589ddb5ad0f628cfc7fe5a971421b65d1f"

const messagevm = @"ciao12"

const messagebtc =
  @"e564c69259497905d0f5a2d1468b5b1eff5386da1aeea735ea4f1d6abba400ca"

test signature_litecoin() {
  let messageHash = generate_message_hash(messagebtc)
  let bytes = string.to_bytearray(messagebtc)
  trace cbor.diagnostic(bytes)
  validate_signature_key(pubkey, messageHash, signature) == True
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
      |> list.push(
          bytearray.from_int_big_endian(redeemer.spendingscriptflag, 1),
        )
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

//TODO, do tests with new hashing functions
const messaggio_frost = @"message to sign"

test test_frost_bitcoin() {
  builtin.verify_schnorr_secp256k1_signature(
    #"50d8bf4b0966b174e9a3b1c48def2a153e17d6450b9e03ea954301a472024072",
    #"3819ff1b5125e14102ae429929e815d6fada758d4a6886a03b1b1c64aca3a53a",
    #"e500505a0946b7848ff53f15a377915f0383efda4492dcb0a7e0cc3a253a89cee3c3fd06a1a870e0b4b2209dc2353c92aa59e399ea1a5490db1d44e0c7a40802",
  )
}

// Test for XVerse Bitcoin wallet signature verification
// Input: tx 7d4123079698c2d931686a20bb167613bde09d3041ce6b1868211594f5eab7f1#0
// Output: addr_test1qqq0cuu96g9hny47un2qcyv7qcs3u70whcdmf06mqj3pkt4wckwszdqepz35tf5h4h9mkce2p4hf3wj239pwhxswwkcq7p5gst with 3 ADA
// Token: 0b77d150c275bd0a600633e4be7d09f83c4b9f00981e22ac9c9d3f62.0014df1074464c4454
const xverse_pubkey =
  #"02c341a570aded9e1cba4930aebff64af210d03473ea0fbfee8a3ab5bea15cd685"

// Base64 signature: JEFmaUH6nAETU7XRImsJmhycVBEHIpy0g7GnE0XITrchNbZHt7oelbCIR0YJtJjKM5K1W8bK5XDkCseGDjjALp0=
// Decoded (65 bytes): 24416669417ea9c013537d1226b099a1c9c54110722c9cb483b1a71345c84eb72135b647b7ba1e95b088474609b498ca3392b55bc6cae570e40ac7860e38c02e9d
// First byte (0x24 = 36) is recovery ID, remaining 64 bytes are r,s signature
const xverse_signature =
  #"a352b6f329420f909283c00fcf54cc3a71d25e1fcc05c8a439757b5b5de219bd0a21fea12f1c47c0c6f7509687bb6651d155599b2c2c7bb08082c107d53ebd5b"

// The hash as hex string (what gets signed with Bitcoin message prefix)
const xverse_message_string =
  @"EE8CF8E07D8F632EE12C1DFDAA53EDDE37753B79F369A95C4C1959544F059A9F"

test signature_xverse_bitcoin_with_prefix() {
  // Test 2: Apply Bitcoin message prefix to the hex string message
  trace @"Test with Bitcoin message prefix:"
  let message_hash_with_prefix = generate_message_hash(xverse_message_string)
  trace cbor.diagnostic(message_hash_with_prefix)
  let result_with_prefix =
    validate_signature_key(
      xverse_pubkey,
      message_hash_with_prefix,
      xverse_signature,
    )
  result_with_prefix == True
}
