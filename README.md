# FluidSwaps Smart Contract - Technical Overview

## Introduction

This repository contains **Cardano smart contracts** for managing **Cross-Chain Atomic Swaps**, written in [Aiken](https://aiken-lang.org).

## Project Structure

```
ft-cardano-fluidswaps-sc-main 3/
├── validators/           # Main smart contracts
│   ├── swap.ak          # Atomic swap contract (HTLC)
│   ├── global.ak        # Asset management and staking contract
│   └── signatures.ak    # Cross-chain signature validation utilities
├── lib/                 # Shared libraries
│   ├── redeemer.ak      # Redeemer type definitions
│   └── constants.ak     # Constants (magic bytes for BTC/ETH)
├── aiken.toml           # Aiken project configuration
├── aiken.lock           # Dependencies lock file
├── plutus.json          # Compiled output (blueprint)
└── README.md            # Basic Aiken documentation
```

## Main Smart Contracts

### 1. `swap.ak` - Atomic Swap Contract (HTLC)

**Purpose**: Implements a **Hash Time-Locked Contract (HTLC)** for cross-chain atomic swaps.

#### Validator Parameters

The contract is parameterized with:

- `hashed_password`: SHA-256 hash of the secret password chosen by the offerer
- `owner_ada_pubkey_hash`: Hash of the Cardano public key of the contract owner
- `_owner_external_chain_pubkey`: Public key of the owner on external blockchain (unused)
- `deadline`: Unix timestamp for contract expiration
- `external_user_chain_pubkey`: Public key of the buyer on external blockchain

#### Supported Redeemers

The contract supports two actions:

##### **Claim** (Redemption)

```aiken
Claim(preimage, signature)
```

Allows unlocking funds by revealing the correct password and providing a valid signature:

1. **Password Verification**: Checks that `sha2_256(preimage) == hashed_password`
2. **Signature Verification**: Validates ECDSA signature (secp256k1) against the buyer's public key
   - Supports both Bitcoin signatures (double SHA-256) and Ethereum signatures (Keccak-256)
   - Uses blockchain-specific "magic bytes" for message signing

##### **Cancel** (Cancellation)

```aiken
Cancel
```

Allows the contract owner to recover funds **after the deadline**:

1. **Deadline Verification**: Checks that the current time is beyond the deadline
2. **Signature Verification**: Requires the owner's signature (`owner_ada_pubkey_hash`)

#### Cross-Chain Hashing Functions

The contract implements two functions to handle differences between Bitcoin and Ethereum:

- **`get_hash_from_bytearray_btc`**: Generates the message hash according to Bitcoin standard
  - Uses double SHA-256
  - Adds magic bytes: `"Bitcoin Signed Message:\n"`
- **`get_hash_from_bytearray_eth`**: Generates the message hash according to Ethereum standard
  - Uses Keccak-256
  - Adds magic bytes: `"Ethereum Signed Message:\n"`

#### Security

- ✅ **Atomicity**: Either both parties receive funds, or no one loses anything
- ✅ **Trustless**: No need to trust third parties
- ✅ **Time-locked**: Deadline-based protection for fund recovery
- ✅ **Cross-chain**: Compatible with Bitcoin and Ethereum via ECDSA secp256k1

---

### 2. `global.ak` - Asset Management & Staking Contract

**Purpose**: Manages complex asset transactions and staking operations on Cardano.

#### Main Features

##### **Spend** - Asset Transfer

```aiken
Send(signature, utxos, chosen_outputs_hash, chosen_outputs_length, signer)
```

Allows spending a UTXO by signing with an external key (Bitcoin/Ethereum):

1. **Signature Validation**: Verifies ECDSA signature on a message containing:
   - List of UTXOs to spend
   - Hash of desired outputs
2. **UTXO Validation**:
   - All signed UTXOs must be present in the transaction
   - Outputs must match the signed hash
3. **Extra Input Protection**:
   - Unsigned inputs must come from the signer's address
   - Prevents addition of unauthorized inputs

##### **Withdraw** - Staking Rewards Withdrawal

Allows withdrawal of staking rewards:

- Verifies that the withdrawn amount goes to the correct address
- Requires a minimum of 10 ADA in rewards
- Deducts 1 ADA as fee

##### **Publish** - Staking Delegation

```aiken
Stake(signature, deadline)
```

Allows delegating stake to a pool by signing with an external key:

1. **Signature Validation**: Verifies signature on message containing:
   - Destination pool ID
   - Transaction deadline
2. **Temporal Validation**: The transaction must complete before the deadline

#### Utility Functions

- **`calculate_address`**: Constructs Cardano addresses with different spending/staking script combinations
- **`calculate_datum`**: Handles inline datum or missing datum
- **`all_inputs_present`**: Verifies presence of all required inputs
- **`all_outputs_present`**: Verifies output correspondence via hash
- **`only_external_signer_inputs_extra`**: Prevents unauthorized inputs

---

### 3. `signatures.ak` - Signature Validation Utilities

**Purpose**: Utility library for signature validation and cross-chain message generation.

#### Main Functions

- **`generate_message_hash`**: Generates message hash for Bitcoin
- **`generate_message_hash_evm`**: Generates message hash for Ethereum
- **`validate_signature_key`**: Validates ECDSA secp256k1 signatures
- **Test Suite**: Includes tests for Bitcoin, Ethereum, and Schnorr signature validation

---

## Shared Libraries

### `lib/redeemer.ak`

Defines the **Redeemer** types used by validators:

```aiken
// For global.ak
pub type Redeemer {
  Send { ... }
  Stake { ... }
}

// For swap.ak
pub type SwapRedeemer {
  Claim { preimage: ByteArray, signature: ByteArray }
  Cancel
}
```

### `lib/constants.ak`

Shared constants for message signing:

```aiken
pub const magic_btc = @"Bitcoin Signed Message:\n"
pub const magic_eth = @"Ethereum Signed Message:\n"
```

---

## Configuration

### `aiken.toml`

```toml
name = "aiken-lang/fluidswaps"
version = "0.0.0"
compiler = "v1.1.9"
plutus = "v3"
```

**Features**:

- Uses **Plutus V3** (latest version)
- Dependency: `aiken-lang/stdlib v2.2.0`
- Compiler: Aiken v1.1.9

---

## How an Atomic Swap Works

### Complete Flow

```
┌─────────────────────────────────────────────────────────┐
│              ATOMIC SWAP FLOW                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1️⃣ OWNER CHOOSES PASSWORD                              │
│    └─ Generates hash: SHA-256(password)                │
│                                                         │
│ 2️⃣ OWNER DEPLOYS CONTRACT ON CARDANO                   │
│    ├─ Locks ADA in swap.ak                             │
│    ├─ Parameters: hashed_password, deadline, pubkeys   │
│    └─ Deadline: e.g. 24 hours                          │
│                                                         │
│ 3️⃣ BUYER DEPLOYS CONTRACT ON BITCOIN/ETHEREUM          │
│    ├─ Locks BTC/ETH in equivalent HTLC                 │
│    ├─ Uses SAME hashed_password                        │
│    └─ Deadline: e.g. 48 hours (longer)                 │
│                                                         │
│ 4️⃣ OWNER CLAIMS BTC/ETH                                │
│    ├─ Reveals password in clear on-chain               │
│    └─ Unlocks buyer's funds                            │
│                                                         │
│ 5️⃣ BUYER CLAIMS ADA                                    │
│    ├─ Uses password revealed by owner                  │
│    ├─ Calls Claim(preimage, signature)                 │
│    └─ Unlocks owner's funds                            │
│                                                         │
│ ✅ SWAP COMPLETED                                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Timeout Scenario

If one party does not act in time:

- **Buyer doesn't fund**: Owner calls `Cancel` after deadline → recovers ADA
- **Owner doesn't claim**: Buyer recovers their funds on their contract
- **No one claims**: Both recover their own funds after respective deadlines

---

## Security and Audit

The project includes:

- **Audit Report**: `FluidSwaps Protocol Smart Contract Audit Report v2_04_Nov_2025.docx.pdf`
- **Audit Explanation**: `FluidSwap_report_explain.pdf`

### Security Features

1. **Hash Time-Lock**: Dual protection via hash and time
2. **Cross-Chain Signature**: ECDSA secp256k1 validation for Bitcoin/Ethereum
3. **Asymmetric Deadlines**: Buyer has more time to protect both parties
4. **Strict UTXO Validation**: Prevents unauthorized inputs/outputs
5. **Comprehensive Tests**: Test suite for each critical functionality

---

## Compilation and Testing

### Build

```bash
aiken build
```

Generates `plutus.json` with the blueprint of compiled contracts.

### Testing

```bash
# Run all tests
aiken check

# Run specific tests
aiken check -m validation
aiken check -m signature
```

### Documentation

```bash
aiken docs
```

Generates HTML documentation of the contracts.

---

## Supported Blockchains

### Cardano (ADA)

- **Contract**: `swap.ak`, `global.ak`
- **Signature**: ECDSA secp256k1 (optional, for compatibility)
- **Hashing**: SHA-256

### Bitcoin (BTC)

- **Contract**: Equivalent HTLC (not in this repo)
- **Signature**: ECDSA secp256k1
- **Hashing**: Double SHA-256 + Bitcoin magic bytes

### Ethereum (ETH)

- **Contract**: Equivalent HTLC (not in this repo)
- **Signature**: ECDSA secp256k1
- **Hashing**: Keccak-256 + Ethereum magic bytes

---

## Resources

- **Aiken Documentation**: [aiken-lang.org](https://aiken-lang.org)
- **Plutus V3**: [docs.cardano.org](https://docs.cardano.org)
- **Atomic Swaps**: [Bitcoin Wiki - Atomic Swap](https://en.bitcoin.it/wiki/Atomic_swap)
