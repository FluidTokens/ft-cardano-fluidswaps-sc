use cardano/address.{Address}
use cardano/transaction.{OutputReference}

pub type Redeemer {
  Send {
    signature: ByteArray,
    utxos: List<OutputReference>,
    chosen_outputs_hash: ByteArray,
    chosen_outputs_length: Int,
    signer: Address,
  }
  Stake { signature: ByteArray, deadline: Int }
}

pub type SwapRedeemer {
  Claim { preimage: ByteArray, signature: ByteArray }
  Cancel
}
