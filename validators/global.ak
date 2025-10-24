use aiken/builtin
use aiken/cbor
use aiken/collection/list
use aiken/collection/pairs
use aiken/crypto.{blake2b_256, keccak_256, sha2_256}
use aiken/interval.{Finite}
use aiken/option.{is_some}
use aiken/primitive/bytearray.{length}
use aiken/primitive/int.{to_string}
use aiken/primitive/string
use cardano/address.{
  Address, Credential, Script, from_script, from_verification_key,
  with_delegation_key, with_delegation_script,
}
use cardano/assets.{from_lovelace}
use cardano/certificate.{
  Certificate, DelegateBlockProduction, DelegateCredential,
}
use cardano/transaction.{
  Datum, InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
  find_input,
}
use constants
use redeemer.{Redeemer, Send, Stake}

validator global(pubKey: ByteArray) {
  spend(
    _datum: Option<Data>,
    redeemer: Redeemer,
    own_ref: OutputReference,
    self: Transaction,
  ) {
    //we'll build the message like this,txid+index+unit+amount+pubkey+stakekeys

    when redeemer is {
      Send(signature, utxos, chosen_outputs_hash, chosen_outputs_length, signer) -> {
        let message_array: List<ByteArray> =
          list.push([], cbor.serialise(utxos))
            |> list.push(cbor.serialise(chosen_outputs_hash))

        let message_hash_btc =
          get_hash_from_bytearray_btc(cbor.serialise(message_array))
        let message_hash_eth =
          get_hash_from_bytearray_eth(cbor.serialise(message_array))

        let flag_utxo_present = list.has(utxos, own_ref)

        let basic_validation = and {
            flag_utxo_present,
            or {
              validate_signature_key(pubKey, message_hash_btc, signature),
              validate_signature_key(pubKey, message_hash_eth, signature),
            },
          }
        //Check 1) The output is sending the right amount
        //Check 2) It is returning the right amount
        //Check 3) Is the right receiver
        //Check 4) Has the datum?
        //Check 5) Are all inputs in utxos present? This is important otherwise I could cancel something random
        //Check 6) Inputs that were not willing to be inside are from the same address and is a user
        //7)Issue now is the expected value coming, this is something we want to sign also? Add input value signed and we are done
        //Let's limit the max amount of outputs to the same wallet, otherwise someone could split all my ada in so many utxos making hard to spend them
        and {
          basic_validation,
          all_inputs_present(utxos, self.inputs),
          all_outputs_present(
            chosen_outputs_hash,
            chosen_outputs_length,
            self.outputs,
          ),
          only_external_signer_inputs_extra(utxos, self.inputs, signer),
        }
      }
      //idealmente qua calcolo il valore totale in input e mi assicuro al contratto vada esattamente quell'ammontare - 2 ADA
      _ -> False
    }
  }

  //anyone can withdraw stake rewards, but only the user can do get them
  withdraw(_redeemer: Redeemer, account: Credential, self: Transaction) {
    when account is {
      Script(hash) -> {
        expect Some(withdrawAmount) = pairs.get_first(self.withdrawals, account)
        expect Some(first_output) = list.at(self.outputs, 0)
        and {
          first_output.value == from_lovelace(withdrawAmount - 1000000),
          first_output.address == (
            from_script(hash) |> with_delegation_script(hash)
          ),
          withdrawAmount > 10000000,
        }
      }

      _ -> False
    }
  }

  publish(redeemer: Redeemer, certificate: Certificate, self: Transaction) {
    expect Stake(signature, deadline) = redeemer
    when certificate is {
      DelegateCredential(_, delegateCredential) -> {
        expect DelegateBlockProduction(poolId) = delegateCredential
        let message_array: List<ByteArray> =
          list.push([], poolId)
            |> list.push(bytearray.from_int_big_endian(deadline, 20))
        let concat_message = concat_array(message_array)
        let message_hash_btc = get_hash_from_bytearray_btc(concat_message)
        let message_hash_eth = get_hash_from_bytearray_eth(concat_message)
        //let message_hash = get_hash_from_bytearray(poolId)
        //TODO missing end in the hash
        and {
          or {
            validate_signature_key(pubKey, message_hash_btc, signature),
            validate_signature_key(pubKey, message_hash_eth, signature),
          },
          validate_tx_end(self, deadline),
        }
      }
      _ -> {
        trace @"finisco qua"
        False
      }
    }
  }

  else(_) {
    fail
  }
}

fn get_hash_from_bytearray_btc(byte: ByteArray) {
  //this is what I sign
  let concat_message =
    string.to_bytearray(bytearray.to_hex(sha2_256(sha2_256(byte))))
  let size = length(concat_message)

  //il doppio sha poi lo rendo stringa e maiuscolo, è quello che firmo
  let final_message =
    bytearray.concat(bytearray.from_int_big_endian(size, 1), concat_message)

  let magic_array = bytearray.from_string(constants.magic_btc)
  let final_magic = bytearray.concat(#"18", magic_array)

  let finalized = bytearray.concat(final_magic, final_message)

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

fn validate_signature_key(publicKey: ByteArray, msg: ByteArray, sig: ByteArray) {
  builtin.verify_ecdsa_secp256k1_signature(publicKey, msg, sig)
}

fn concat_array(list_array: List<ByteArray>) {
  list.reduce(list_array, #[], bytearray.concat)
}

fn validate_tx_end(tx: Transaction, deadline: Int) {
  trace cbor.diagnostic(deadline)
  when tx.validity_range.upper_bound.bound_type is {
    Finite(end) -> end < deadline
    _ -> False
  }
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

pub fn calculate_datum(flag_datum: Int, datum: Data) -> Datum {
  if flag_datum == 0 {
    NoDatum
  } else {
    InlineDatum(datum)
  }
}

pub fn all_inputs_present(
  utxos_chosen: List<OutputReference>,
  real_utxos: List<Input>,
) {
  list.all(utxos_chosen, fn(input) { is_some(find_input(real_utxos, input)) })
}

pub fn all_outputs_present(
  outputs_chosen_hash: ByteArray,
  length: Int,
  real_outputs: List<Output>,
) {
  hash(cbor.serialise(list.slice(real_outputs, 0, length))) == outputs_chosen_hash
}

pub fn only_external_signer_inputs_extra(
  utxos_chosen: List<OutputReference>,
  real_utxos: List<Input>,
  address_signer: Address,
) {
  let list_external =
    list.filter(
      real_utxos,
      fn(input) { !list.has(utxos_chosen, input.output_reference) },
    )
  list.all(list_external, fn(input) { input.output.address == address_signer })
}

pub fn hash(data: Data) {
  blake2b_256(cbor.serialise(data))
}
