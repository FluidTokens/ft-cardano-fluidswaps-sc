# Fluid Swap Docs

## Fluid Swap

**Fluid Swap** is a decentralized platform that allows you to exchange cryptocurrencies between different blockchains securely, without intermediaries. You can create and accept swap offers between **Cardano (ADA)**, **Bitcoin (BTC)** and **Ethereum (ETH)** leveraging **atomic swap** technology.

### Who This Guide Is For

This guide is designed for all users who want to:

- **Exchange cryptocurrencies** between different blockchains without using centralized exchanges
- **Create personalized swap offers** (e.g., "I offer 2000 ADA for 1.5 BTC")
- **Accept offers** created by other users
- **Understand the process** from beginning to end

No in-depth technical knowledge of blockchain or smart contracts is required.

### What You Can Do On The Platform

✅ **Navigate the public marketplace** without registration
✅ **Create personalized swap offers**
✅ **Accept offers** posted by others
✅ **Execute atomic swaps** securely and trustless
✅ **Monitor your active swaps** in real-time
✅ **Manage your offers** (drafts, active, completed)

---

## Table of Contents

1. [Key Roles and Concepts](#key-roles-and-concepts)
2. [First Access: Wallet Connection](#first-access-wallet-connection)
3. [Create a New Offer](#create-a-new-offer)
4. [Navigate the Marketplace](#navigate-the-marketplace)
5. [Accept an Offer](#accept-an-offer)
6. [Execute an Atomic Swap](#execute-an-atomic-swap)
7. [Manage Your Offers and Swaps](#manage-your-offers-and-swaps)
8. [How Smart Contracts Work](#how-smart-contracts-work)
9. [Best Practices and Tips](#best-practices-and-tips)

---

## Key Roles and Concepts

### The Two Roles in a Swap

#### 🟦 Offerer (Owner)

- **Who**: The person who creates the offer
- **What they do**:
  - Decide what to offer and what to request in return
  - Publish the offer on the marketplace
  - Lock their funds first when someone accepts
  - Claim the buyer's funds by revealing a secret password

**Example**: Mario creates an offer "I offer 2000 ADA, I want 1.5 BTC"

#### 🟨 Buyer

- **Who**: The person who accepts an existing offer
- **What they do**:
  - Browse the marketplace and choose an offer
  - Accept the offer and lock their funds
  - Wait for the offerer to reveal the password
  - Claim the offerer's funds using the revealed password

**Example**: Lucia sees Mario's offer and accepts it because she has BTC and wants ADA

### What is an Atomic Swap?

An **atomic swap** is an exchange between two people that guarantees:

✅ **All or nothing**: Either both receive funds, or neither loses anything
✅ **No intermediary**: No need for exchanges or third parties
✅ **Cross-chain**: Works between different blockchains (BTC ↔ ADA ↔ ETH)
✅ **Secure**: Protected by smart contracts and blockchain scripts

**How it works in brief**:

1. The offerer chooses a secret password and locks their funds in a contract
2. The buyer locks their funds (the system automatically uses the hash of the same password)
3. The buyer reveals the password to take the offerer's funds
4. The offerer uses the revealed password to take the buyer's funds

If someone doesn't complete their part within the set time, the other can **recover their funds** automatically.

### What is a Hash Time-Locked Contract (HTLC)?

It's the mechanism that makes atomic swaps secure. Think of it as a **smart lock**:

🔐 **Hash Lock**: Needs the correct password to open it
⏱️ **Time Lock**: After a set time, the original owner can reopen it even without the password

This guarantees that:

- Only whoever knows the password can take the funds
- If the other party doesn't act, you can recover your funds after expiration

---

## First Access: Wallet Connection

### Why Two Wallets Are Needed

Fluid Swap requires **connecting two wallets from different blockchains** to verify your identity and allow you to operate on both networks.

**Example**: If you want to exchange BTC for ADA, you must connect:

- A Bitcoin wallet (e.g., Unisat)
- A Cardano wallet (e.g., Eternl)

### Supported Wallets

#### 🟠 Bitcoin (BTC)

- Unisat
- XVerse
- Leather
- MagicEden
- OKX

#### 🔵 Cardano (ADA)

- Eternl
- Gero
- Typhon
- Lace
- Yoroi
- NuFi
- Begin
- Vespr
- OKX
- Tokeo
- Metamask

#### 🟣 Ethereum (ETH)

- MetaMask
- MagicEden

### Connection Procedure (Step-by-Step)

#### Step 1: Click "Connect Wallets"

When you visit the platform for the first time, click the **"Connect Wallets"** button in the header.

A popup will open in 3 phases.

---

#### Step 2: Connect the First Wallet

**What to do**:

1. **Click on the wallet** of the blockchain you prefer (e.g., Eternl for Cardano)
2. The browser extension for your wallet opens
3. **Approve the connection** in your wallet
4. Your wallet will ask you to **sign a message** to verify you own this wallet
5. **Sign the message** (it's free, just a verification)
6. You'll see a checkmark ✅ next to the connected wallet
7. The **"Next"** button becomes active

**Highlight**: ⚡ The signature is free and only serves to prove you own that wallet

---

#### Step 3: Connect the Second Wallet

**What to do**:

1. **Click on the wallet** of a **DIFFERENT** blockchain from the first one (e.g., Unisat for Bitcoin)
2. **Approve the connection** in the wallet extension
3. **Sign the verification message**
4. You'll see a checkmark ✅
5. The **"Next"** button becomes active

**Highlight**: 🔄 You must choose a different chain from the first one (you can't connect two Cardano wallets)

---

#### Step 4: Review and Verify

**What to do**:

1. **Check** that the wallets shown are correct
2. Click **"Verify & Complete Connection"**
3. The system verifies the signatures on the backend
4. If everything is correct, you're authenticated! ✅

**What happens after**:

- The popup closes
- In the header you'll see your profile instead of the "Connect Wallets" button
- You can click on your profile to see your connected wallets
- Now you can create offers and accept offers

**Highlight**: 🔐 Your identity is verified on-chain, no password to remember!

---

## Create a New Offer

### Where to Create an Offer

You can create offers from:

- **Homepage** (right after connecting)
- **Dashboard** → "Create Offer" button

### Creation Procedure (Step-by-Step)

#### Step 1: Open the Creation Form

In the form you'll see two sections: "I offer" (what you're offering) and "I want" (what you want to receive).

---

#### Step 2: Select the Asset You're Offering

**What to do**:

1. Click on **"Select Asset"** in the "I offer" section
2. A popup opens with the list of available assets
3. **Search** for the asset you want to offer (e.g., ADA, BTC, ETH)
4. **Click on the asset** to select it
5. The asset appears in the form with the blockchain logo

**Example**: You select "ADA" (Cardano)

**Highlight**: 💡 You can only offer assets from blockchains for which you've connected a wallet

---

#### Step 3: Enter the Amount You're Offering

**What to do**:

1. In the **"Amount"** field of the "I offer" section
2. Enter the amount you want to offer (e.g., `2000`)
3. The system will display the amount with the correct decimals

**Example**: You enter `2000` → you see "2000 ADA"

---

#### Step 4: Select the Asset You Want to Receive

**What to do**:

1. Click on **"Select Asset"** in the "I want" section
2. The popup opens
3. **Note**: You can only select an asset from a blockchain **different** from the one you're offering from
4. **Click on the desired asset** (e.g., BTC)

**Example**: You select "BTC" (Bitcoin)

**Highlight**: 🔄 You can't exchange assets from the same blockchain (e.g., ADA for ADA)

---

#### Step 5: Enter the Amount You Want to Receive

**What to do**:

1. In the **"Amount"** field of the "I want" section
2. Enter the amount you want to receive (e.g., `1.5`)
3. The system will display "1.5 BTC"

---

#### Step 6: Create the Offer

**What to do**:

1. Check that everything is correct:
   - Offering: 2000 ADA
   - Want: 1.5 BTC
2. Click **"Create Offer"**
3. The offer is saved as **DRAFT** (draft)
4. You're redirected to the offer detail page

**Highlight**: 📝 Offers in DRAFT are private and editable

---

#### Step 7: Choose the Password for the Swap

**IMPORTANT**: This is a **crucial** step for swap security!

**What to do**:

1. On the offer DRAFT page, click **"Publish"**
2. A popup opens asking you to **enter a password** for the swap
3. **Choose a strong password** (at least 4 characters, but longer is better)

**Password Characteristics**:

- ✅ **Unique**: Don't reuse passwords from other services
- ✅ **Strong**: Combine letters, numbers, and symbols
- ✅ **Long**: At least 8-12 characters (even though the minimum is 4)
- ✅ **Memorable or saveable**: You'll need to use it during the swap

**Why it's important**:

- This password **locks the funds** in the smart contracts
- Only someone who knows the password can claim the funds (along with wallet signature)
- If you lose it, **you won't be able to complete the swap**
- The password will be **revealed publicly** on the blockchain when you claim

4. Enter the password in the field
5. Click **"Confirm & Publish"**

**What happens**:

- The system calculates the **hash of the password** (SHA-256)
- The hash will be used in smart contracts (not the plain password)
- You're shown the password in a confirmation popup
- **Copy and save the password** in a secure place!
- The offer becomes **ACTIVE** and visible in the marketplace

**Highlight**: 🔑 ALWAYS SAVE THE PASSWORD! You'll need it when someone accepts the offer

**Example of a strong password**:

- ✅ `MySecretSwap2024!` (strong, with uppercase, numbers, and symbols)
- ✅ `cardano-btc-swap-jan-2026-secure` (descriptive and long)
- ✅ `7hG$kL2pQw9*XzN4` (randomly generated, very secure)
- ❌ `1234` (too weak, avoid!)
- ❌ `password` (too common, avoid!)
- ❌ `mypassword123` (predictable, avoid!)

---

#### Step 8: Password Revealed - Save It!

After publishing, you'll see a popup with the password you chose:

**Important Actions**:

1. **Copy the password** (click the "Copy to Clipboard" button)
2. **Save it** in:
   - A password manager (1Password, Bitwarden, etc.)
   - An encrypted file
   - A secure offline location
3. **DON'T share it** with anyone before the swap starts
4. Click **"I've Saved My Password"** to close the popup

**Highlight**: ⚠️ If you lose the password, you WON'T be able to complete the swap!

---

#### Step 9: Offer Published

Now the offer is **ACTIVE**:

- Visible on the `/offers` page (public marketplace)
- Other users can see it and accept it
- You can still edit or cancel it if no one has accepted it yet

**Highlight**: ✅ The offer is live! Wait for someone to accept it

---

## Navigate the Marketplace

### Access the Marketplace

The public marketplace is accessible to everyone, **even without connecting wallets**.

**How to get there**:

- From the header, click **"OFFERS"**
- Or go directly to `/offers`

### Elements of an Offer Card

Each card shows:

- **Offered assets** with logo and amount (e.g., 1.5 BTC)
- **Arrow ↔** indicating the exchange
- **Requested assets** with logo and amount (e.g., 2000 ADA)
- **Blockchain** of each asset
- **Creation date**
- **"View Details"** button to see full details

**Highlight**: 🔍 You can filter and search offers (future functionality)

---

## Accept an Offer

### Prerequisites

Before accepting an offer, make sure:

✅ You've **connected wallets** from the two blockchains involved
✅ You have **sufficient funds** in the asset requested by the offer
✅ You've **understood the atomic swap process**

### Acceptance Procedure (Step-by-Step)

#### Step 1: View Offer Details

**What to do**:

1. In the marketplace, click **"View Details"** on an offer that interests you
2. You're redirected to the detail page (`/offers/[id]`)

**On the detail page you see**:

- Offered and requested assets with amounts
- Price ratio (exchange rate)
- Creation date
- Information about the owner
- Summary: "You will send: X / You will receive: Y"
- **"Accept Offer"** button

---

#### Step 2: Verify the Details

**What to check**:

✅ **Correct amounts**: Make sure the amount to send and the one to receive are right
✅ **Correct blockchains**: Verify that the chains are supported by your wallets
✅ **Price ratio**: Check that the exchange rate is acceptable to you

**Highlight**: ⚠️ Always check the amounts before accepting!

---

#### Step 3: Click "Accept Offer"

**What to do**:

1. If you agree, click **"Accept Offer"**
2. The system verifies you're authenticated
3. If you're not authenticated, it asks you to connect wallets

**What happens behind the scenes**:

- The system retrieves the **secret password** chosen by the owner when they published the offer
- Uses the **hash of the password** (SHA-256) already calculated
- Changes the offer status from `ACTIVE` to `ACCEPTED`
- Associates you as the **buyer** of the offer
- Generates **deadlines** for transactions (e.g., 24h for Cardano, 48h for Bitcoin)

**Highlight**: 🔐 The password is the one chosen by the owner, you don't know it yet

---

#### Step 4: Redirection to Swap Flow

After accepting, you're **automatically redirected** to the swap page:

```
/dashboard/swaps/[id]
```

Here begins the true **atomic swap** process in 4 steps. You'll see a timeline showing:

1. ⏳ Deploy Owner Contract - The owner must act first
2. ⏹ Fund Buyer Contract - You'll act after the owner
3. ⏹ Owner Claims (reveals password) - The owner claims and reveals the password
4. ⏹ Buyer Claims - You claim using the revealed password

**Highlight**: 🚀 Now the swap is officially in progress!

---

## Execute an Atomic Swap

This is the main part of the process. The swap happens in **4 sequential steps**.

### Overview of the 4 Steps

```
┌─────────────────────────────────────────────────────────┐
│              ATOMIC SWAP TIMELINE                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1️⃣ OWNER DEPLOYS CONTRACT                              │
│    ├─ Owner locks their funds (e.g., 1.5 BTC)          │
│    ├─ Uses a secret password (in hash format)          │
│    └─ Deadline: 24 hours                               │
│                                                         │
│ 2️⃣ BUYER FUNDS CONTRACT                                │
│    ├─ Buyer (you) lock your funds (e.g., 2000 ADA)     │
│    ├─ Use the same owner's password hash               │
│    └─ Deadline: 48 hours (longer than first)           │
│                                                         │
│ 3️⃣ OWNER CLAIMS                                         │
│    ├─ Owner claims buyer's funds (2000 ADA)            │
│    ├─ To do so, REVEALS the password in clear          │
│    └─ The password becomes public on the blockchain    │
│                                                         │
│ 4️⃣ BUYER CLAIMS                                         │
│    ├─ Buyer (you) see the password revealed             │
│    ├─ Use the password to claim owner's funds          │
│    └─ Take 1.5 BTC! ✅                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

### Step 1: Owner Deploy Contract

#### Who acts: **Offerer (Owner)**

**What the owner must do**:

1. Access `/dashboard/swaps/[id]`
2. See a card **"YOUR REQUIRED ACTION"**
3. Click **"Connect & Sign Transaction"**

**The owner sees**:

- Required action: "Deploy Cardano Contract" (or Bitcoin/Ethereum depending on the chain)
- Time remaining (e.g., 23h 45m)
- Amount to lock (e.g., 1.5 BTC)
- "Connect & Sign Transaction" button

**What happens when they click**:

1. The **wallet extension** opens (e.g., Unisat for Bitcoin)
2. Your wallet shows a transaction to **sign**
3. The transaction **locks the funds** (1.5 BTC) in a special script/contract
4. The owner **approves and signs**
5. The transaction is sent to the blockchain
6. The interface shows **"Awaiting Confirmation..."**
7. After a few minutes, the transaction is **confirmed** ✅

**Highlight**: 🔐 The owner's funds are now locked in an on-chain contract

---

#### What the buyer sees during this step

**The buyer sees**:

- Message: "Waiting for Owner to deploy contract"
- Timeline showing step 1 in progress (⏳)
- "Refresh Status" button to update

**Highlight**: 🕐 The buyer can only wait during this step

---

### Step 2: Buyer Funds Contract

#### Who acts: **Buyer (You!)**

Once the owner's contract is confirmed, the page updates automatically.

**The buyer sees**:

- Required action: "Fund Bitcoin Contract" (or another chain)
- Time remaining (e.g., 47h 30m)
- Amount to lock (e.g., 2000 ADA)
- "Connect & Sign Transaction" button

**What to do**:

1. Click **"Connect & Sign Transaction"**
2. Your Cardano wallet opens (e.g., Eternl)
3. You see a transaction that **locks 2000 ADA**
4. **Sign the transaction**
5. Wait for confirmation (a few minutes)

**What happens**:

- Your 2000 ADA are locked in a Cardano smart contract
- The contract requires the **same password** (in hash format) that the owner used
- The transaction is recorded on-chain

**Highlight**: 🔗 Now both contracts are deployed and the funds are locked!

---

#### What the owner sees during this step

**The owner sees**:

- Message: "Waiting for Buyer to fund contract"
- Timeline: Step 1 completed ✅, Step 2 waiting ⏳
- "Refresh Status" button

**Highlight**: ⏱️ The owner must wait for the buyer to complete their step

---

### Step 3: Claim with Password Revelation

#### Who acts: Depends on the direction of the swap

**IMPORTANT**: Who reveals the password depends on who claims **first** for the other's asset.

**Logic**:

- Who **requests** an asset and claims it first → **Reveals the password**
- The other then uses the revealed password to complete the swap

**Example**:

- Owner offers 2000 ADA, requests 1.5 BTC
- Owner claims the 1.5 BTC **by revealing the password**
- Buyer uses the password to claim the 2000 ADA

---

#### Generic Scenario: First Claim

**Who claims first sees**:

- Required action: "Claim [ASSET]" (e.g., "Claim 1.5 BTC")
- Time remaining
- Warning: "⚠️ This will reveal your password on the blockchain"
- "Connect & Sign Transaction" button

**What to do**:

1. Click **"Connect & Sign Transaction"**
2. Your wallet opens
3. Sign the **claim** transaction

**What happens**:

- The transaction includes the **password in clear** (revealed on-chain)
- The funds are transferred to your wallet
- **The password is now public** on the blockchain!

**Highlight**: 🔓 The password is now visible to everyone on the blockchain!

---

#### What the other party sees

**The other party sees**:

- Message: "Waiting for counterparty to claim and reveal password"
- Timeline: Step 3 waiting ⏳

As soon as the transaction is confirmed, they receive a **notification** with the revealed password.

**Notification**:

- Title: "🎉 PASSWORD REVEALED!"
- Password shown in clear
- "Copy to Clipboard" button
- Message: "You can now claim your funds!"

**Highlight**: 🔑 Now you can use the password to complete the swap!

---

### Step 4: Second Claim (with Revealed Password)

#### Who acts: The other party who was waiting

It's time to finish: you can claim the other's funds using the revealed password!

**Who claims second sees**:

- Required action: "Claim [ASSET]" (e.g., "Claim 2000 ADA")
- Time remaining
- **Revealed password** shown clearly
- "Connect & Sign Transaction" button

**What to do**:

1. **Copy the password** if you haven't already
2. Click **"Connect & Sign Transaction"**
3. Your wallet opens
4. Sign the **claim** transaction

**What happens**:

- The transaction uses the **revealed password** to unlock the funds
- The funds are transferred to your wallet
- The swap is **completed** ✅

**Highlight**: 🎊 Swap completed successfully! Both have received the funds

---

### Swap Completed!

When both parties have claimed the funds, you'll see the completion screen with:

**Information shown**:

- 🎉 Title: "Atomic Swap Successfully Completed!"
- Complete timeline with all steps ✅
- **Transaction Details** with blockchain explorer links
- **Final Settlement** with final amounts exchanged
- Status: COMPLETED ✅
- Buttons to return to marketplace or create new offers

**Highlight**: ✅ Swap completed successfully! Both have received the funds

---

### What Happens If Someone Doesn't Act? (Timeout)

Atomic swaps have **deadlines** to protect both parties.

#### Scenario 1: The Buyer Doesn't Fund the Contract

**Situation**:

- The owner has deployed their contract (locked the funds)
- The buyer **doesn't fund** their contract before the deadline

**What the owner can do**:

1. After the deadline, they see: "⚠️ DEADLINE EXPIRED"
2. Message: "The buyer did not fund their contract in time"
3. Available button: **"Reclaim My [ASSET]"**
4. They click the button
5. They sign the transaction in their wallet
6. Their funds are **returned** to their wallet
7. The offer status changes to **EXPIRED**

**Highlight**: 🔄 No one loses funds, the owner gets their assets back

---

#### Scenario 2: No One Claims In Time

**Situation**:

- Both have funded their contracts
- But no one claims within the deadlines

**What each can do**:

After their own deadline expires, each can **recover their own funds**:

1. They see: "⚠️ DEADLINE EXPIRED"
2. Message: "The counterparty did not claim in time"
3. Available button: **"Reclaim My [ASSET]"**
4. They click the button and sign the transaction
5. Their funds are **returned** to their original wallet
6. The offer status changes to **EXPIRED**

**Highlight**: 🛡️ Deadlines protect both parties from losing funds

---

## Manage Your Offers and Swaps

### Dashboard Overview

When you access the dashboard (`/dashboard`), you see an overview of your activities organized in three main sections.

### Dashboard Sections

#### 1️⃣ Requires Attention (Red Cards)

**What it shows**:

- Swaps that require **immediate action** from you
- Have **urgent deadlines** (< 24 hours)
- Ordered by **urgency** (closest deadline first)

**Available Actions**:

- **Take Action**: Takes you directly to the swap flow to complete the action

**Highlight**: ⚠️ Check this section regularly to not miss deadlines!

---

#### 2️⃣ Waiting for Counterparty (Yellow Cards)

**What it shows**:

- Swaps where you've completed your part
- You're waiting for the other party to act
- No immediate urgency for you

**Example**:

- You've funded the contract, waiting for the owner to claim
- The owner has claimed, but you haven't yet (but no urgency)

**Highlight**: 🕐 You can relax, waiting for the other party

---

#### 3️⃣ Active Offers (Blue Cards)

**What it shows**:

- Your offers with **ACTIVE** status
- Visible in the public marketplace
- Other users can accept them

**Available Actions**:

- **View All**: Takes you to `/dashboard/offers` to see all offers

---

### Manage Offers

Go to `/dashboard/offers` to see **all your offers** in grid format. Each card shows:

- Offered and requested assets
- Status (colored badge)
- Creation date
- "View" or "Edit" button

**Possible statuses**:

- **DRAFT**: Draft, private, editable
- **ACTIVE**: Public, visible in marketplace
- **ACCEPTED**: Swap in progress
- **COMPLETED**: Swap successfully completed
- **CANCELLED**: Offer cancelled by you
- **EXPIRED**: Expired without completion

**Highlight**: 📊 You can see your complete offer history

---

### Manage Active Swaps

Go to `/dashboard/swaps` to see **all active swaps** in grid format. Each card shows:

- Assets involved in the swap
- Urgency indicator (colored icon)
- Time remaining
- "View" button for details

**Card Colors**:

- 🔴 **Red**: Urgent action required (< 24h)
- 🔵 **Blue**: Action required (not urgent)
- 🟡 **Yellow**: Waiting for counterparty
- 🟢 **Green**: Successfully completed
- ⚫ **Gray**: Cancelled or expired

**Highlight**: 🎯 Focus on the red and blue cards!

---

## How Smart Contracts Work

### Why Smart Contracts Make Fluid Swap Secure

Smart contracts are **automatic programs** executed on blockchains. They can't be modified or stopped once started.

#### 🔐 Security Guarantees

**1. Atomicity**

- **All or nothing**: Either both receive funds, or neither loses anything
- Can't happen that one receives and the other doesn't

**2. Trustless (No Trust Needed)**

- **No need to trust** the other person
- No need to trust Fluid Swap as a platform
- Contracts execute the rules automatically

**3. Decentralized**

- **No intermediary** can block or steal funds
- No "admin" who controls the contracts
- Everything is verifiable on-chain

**4. Time-Locked (Deadline Protected)**

- **If the other party doesn't act**, you can recover your funds
- Deadlines prevent funds from being locked forever

---

### The Three Smart Contracts

Fluid Swap uses **three different implementations** of the same mechanism (HTLC) for the three blockchains.

#### 🔵 Cardano Smart Contract (Aiken)

**How it works**:

1. The owner locks their ADA in the contract with:
   - A **password hash** (e.g., SHA-256 of "mysecret123")
   - Their **Cardano public key** (for reclaim)
   - The **Bitcoin/Ethereum public key** of the buyer (for verification)
   - A **deadline** (e.g., 24 hours)

2. The buyer can claim the ADA only if:
   - They provide the **correct password** (matching the hash)
   - They sign with their **Bitcoin/Ethereum wallet** (proof of ownership)

3. The owner can recover the ADA if:
   - The **deadline has expired**
   - They sign with their **Cardano wallet**

**Highlight**: 🛡️ The contract verifies signatures from other blockchains (BTC/ETH) thanks to ECDSA cryptography

---

#### 🟠 Bitcoin Script (P2WSH)

**How it works**:

1. The buyer locks their BTC in a **Bitcoin script** with:
   - The **password hash** (same as owner's)
   - The **buyer's public key** (for timeout path)
   - The **owner's public key** (for claim path)
   - A **deadline** (e.g., 48 hours)

2. The owner can take the BTC if:
   - They provide the **correct password**
   - They sign with their **Bitcoin wallet**

3. The buyer can recover the BTC if:
   - The **deadline has expired**
   - They sign with their **Bitcoin wallet**

**Highlight**: 🔓 When the owner reveals the password to take the BTC, the password becomes **public** on the Bitcoin blockchain

---

#### 🟣 Ethereum Smart Contract (Solidity)

**How it works**:

1. Similar to the others, the contract locks ETH with:
   - **Password hash**
   - **Alice** and **Bob** addresses
   - **Deadline**

2. Bob can claim if they provide:
   - Correct password
   - Valid signature

3. Alice can recover after the deadline

**Highlight**: 🔗 All three contracts use the **same password hash**, guaranteeing atomicity

---

### What Does the System Guarantee?

#### ✅ Happy Scenario (Complete Swap)

```
Owner locks funds → Buyer locks funds → Owner reveals password → Buyer uses password
     ✅                    ✅                    ✅                     ✅
   (BTC locked)        (ADA locked)        (ADA → Owner)         (BTC → Buyer)
```

**Result**: Both have successfully exchanged funds!

---

#### ✅ Timeout Scenario (No One Loses Funds)

**Case 1: Buyer doesn't fund**

```
Owner locks funds → Buyer DOESN'T fund → Deadline expires → Owner reclaims
     ✅                    ❌                  ⏰              ✅
   (BTC locked)        (timeout)          (expired)    (BTC returned)
```

**Result**: Owner recovers their BTC, no one loses anything

---

**Case 2: Owner doesn't claim**

```
Owner locks → Buyer locks → Owner DOESN'T claim → Deadline expires → Both reclaim
     ✅            ✅                 ❌                  ⏰              ✅
  (BTC locked) (ADA locked)        (timeout)          (expired)   (funds returned)
```

**Result**: Both recover their own funds, no one loses anything

---

### Why Is the Password Secure?

**Question**: If the password becomes public, isn't it insecure?

**Answer**: No, because:

1️⃣ The password is **chosen by the owner** when publishing the offer (must be strong, min. 4 characters)
2️⃣ Only the **password hash** is public in the contracts (SHA-256), not the password itself
3️⃣ The password in clear is revealed **only when someone claims**, when the swap is almost complete
4️⃣ Even if revealed, **only the other party can use it** (because the correct wallet signature is also needed)

**Highlight**: 🔑 The password is like a "one-time unlock code" for this specific swap

**Security Advice**:

- Always choose a **strong and unique** password for each swap
- Don't reuse passwords from other services
- Save the password in a password manager or a secure place

---

## Best Practices and Tips

### Security Tips

1. **Always verify amounts** before accepting an offer
2. **Save your password** in a secure place (password manager recommended)
3. **Use strong passwords** (at least 8-12 characters with letters, numbers, symbols)
4. **Check exchange rates** to ensure they're fair
5. **Monitor your deadlines** to not miss claiming your funds

### Tips for Successful Swaps

1. **Start small**: Try a small swap first to understand the process
2. **Check wallet balance**: Ensure you have enough funds before accepting
3. **Be punctual**: Act promptly to avoid deadline issues
4. **Stay informed**: Keep monitoring your dashboard
5. **Contact support**: If issues arise, reach out to the support team

### Common Issues

**Issue**: "My wallet doesn't connect"
- **Solution**: Ensure the browser extension is installed and unlocked

**Issue**: "Transaction keeps failing"
- **Solution**: Check that you have enough ADA/BTC/ETH for fees

**Issue**: "I missed the deadline"
- **Solution**: You can reclaim your funds after the deadline expires

---

## Conclusion

**Fluid Swap** allows you to exchange cryptocurrencies between different blockchains securely and decentralized. **Atomic swaps** guarantee that:

✅ Either both receive funds, or no one loses anything
✅ No need to trust intermediaries
✅ Everything is protected by verifiable smart contracts on-chain

Following this guide and best practices, you can:

- **Create** personalized offers
- **Accept** existing offers
- **Complete** swaps securely
- **Manage** your activities from the dashboard

**Get started now**:

1. Connect your wallets
2. Explore the marketplace
3. Create your first offer (start with small amounts!)

Happy swapping! 🚀

---

## Appendix: Glossary

**Atomic Swap**: Cross-chain exchange that guarantees "all or nothing"
**HTLC**: Hash Time-Locked Contract, mechanism that locks funds with password and deadline
**Hash**: "Fingerprint" of data (e.g., SHA-256 of a password)
**Deadline**: Maximum time to complete an action
**Redeemer**: Parameter that specifies how to unlock funds from a Cardano contract
**P2WSH**: Pay to Witness Script Hash, Bitcoin transaction type for complex scripts
**Claim**: Claim funds locked in a contract
**Reclaim**: Recover your own funds after a deadline expires
**Owner**: Creator of the swap offer
**Buyer**: Person who accepts the offer
**Fee**: Cost for sending an on-chain transaction
**Seed Phrase**: Wallet recovery phrase (keep it secret!)

---

**Documentation Version**: 1.0
**Last Update**: January 2026
**Platform**: Fluid Swap
**Supported Blockchains**: Cardano, Bitcoin, Ethereum
