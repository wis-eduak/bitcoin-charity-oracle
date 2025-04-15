# Bitcoin Charity Oracle (BCO)

## Overview

**Bitcoin Charity Oracle (BCO)** is a decentralized price oracle and charitable donation platform built for the [Stacks](https://www.stacks.co) ecosystem. This smart contract enables transparent, Bitcoin-denominated charitable giving with real-time, reliable price feeds and on-chain verification through NFTs.

By combining multiple price providers with a robust donation management system, BCO ensures verifiable, secure, and impactful contributions to charitable causes on the Bitcoin network via Stacks smart contracts.

---

## Features

- **Decentralized Price Oracle:** Aggregates and validates Bitcoin price data from multiple providers.
- **Donation Management System:** Enables creation and funding of charitable causes.
- **NFT Certificates:** Issues NFTs as verifiable proof of donation.
- **Price Aggregation and Validation:** Ensures price accuracy via thresholds, deviations, and block freshness.
- **Transparent Fund Tracking:** All cause and donation data is on-chain and queryable.

---

## Architecture

The contract is divided into four primary modules:

### 1. Oracle Management

- Adds and removes authorized price providers.
- Validates submitted price data based on pre-set constraints.
- Stores per-provider price and block data for aggregation.

### 2. Donation Platform

- Allows users to create charitable causes with funding targets and recipients.
- Handles donation records and updates funding progress.

### 3. NFT Certificates

- Mints a unique NFT for each donor per cause as proof of contribution.

### 4. Price Aggregation

- Collects price submissions, calculates a consensus price, and stores it as the current market price.
- Enforces constraints such as valid price ranges, deviation limits, and provider count thresholds.

---

## Constants

| Name                  | Description                                        | Value / Type              |
| --------------------- | -------------------------------------------------- | ------------------------- |
| `PRICE_PRECISION`     | Decimal scaling for BTC price                      | `u100000000` (8 decimals) |
| `MAX_PRICE_AGE`       | Max age in blocks before price is considered stale | `u900` (≈15 minutes)      |
| `MIN_PRICE_PROVIDERS` | Minimum providers for valid aggregation            | `u3`                      |
| `MAX_PRICE_PROVIDERS` | Maximum allowed providers                          | `u10`                     |
| `MAX_PRICE_DEVIATION` | Max deviation from median price (%)                | `u200` (20%)              |
| `MIN_VALID_PRICE`     | Lower bound for submitted BTC price                | `u100000`                 |
| `MAX_VALID_PRICE`     | Upper bound for submitted BTC price                | `u1000000000`             |

---

## Error Codes

| Code   | Message                                |
| ------ | -------------------------------------- |
| `u100` | Not authorized                         |
| `u101` | Price data is stale                    |
| `u102` | Insufficient number of price providers |
| `u103` | Price is below minimum threshold       |
| `u104` | Price is above maximum threshold       |
| `u105` | Price deviates too much from median    |
| `u106` | Price cannot be zero or not found      |
| `u107` | Invalid block height provided          |
| `u108` | Provider already exists                |
| `u111` | Invalid cause name                     |
| `u112` | Invalid target value                   |
| `u113` | Invalid recipient address              |

---

## Oracle Management

### Add Provider

```clojure
(add-price-provider provider)
```

Adds a new price provider. Only the contract owner can perform this.

### Remove Provider

```clojure
(remove-price-provider provider)
```

Removes an existing provider.

### Submit Price

```clojure
(submit-price price)
```

Authorized providers submit a BTC price. If enough valid submissions exist, the median price is stored as the current price.

---

## Donation Platform

### Create Cause

```clojure
(create-cause name target recipient)
```

Creates a new charitable cause with a goal and a designated recipient address.

### NFT Minting (Private)

```clojure
(mint-certificate donor cause-id)
```

Mints a unique NFT certificate to a donor for a specific cause.

---

## Read-Only Functions

### Oracle Queries

```clojure
(get-current-price)               ;; Gets latest valid BTC price
(get-price-provider-count)       ;; Returns count of active providers
(get-provider-status provider)   ;; True if provider is active
(get-last-update-block)          ;; Last block where price was updated
(get-historical-price block)     ;; Returns BTC price at a block
```

### Donation Queries

```clojure
(get-cause cause-id)                          ;; Returns cause info
(get-donation donor cause-id)                 ;; Returns donor's donation info
```

---

## Data Structures

### Causes

```clojure
(map causes (tuple (cause-id uint))
     (tuple (name (string-ascii 64))
            (target uint)
            (raised uint)
            (recipient principal)))
```

### Donations

```clojure
(map donations
     (tuple (donor principal) (cause-id uint))
     (tuple (amount uint) (timestamp uint)))
```

### Price Providers & Data

- `price-providers`: Maps provider to active status
- `provider-prices`: Stores latest price by provider
- `provider-last-update`: Stores last update block per provider
- `active-provider-list`: Indexes active providers
- `historical-prices`: Block-indexed price snapshots

---

## Non-Fungible Tokens

- **Name:** `donation-certificate`
- **ID:** Incremental per mint
- **Purpose:** Issued once per donor per cause as immutable, on-chain proof of donation.

---

## Deployment Notes

- Ensure contract ownership is correctly assigned at deployment (`CONTRACT_OWNER = tx-sender`).
- Only the contract owner can manage providers.
- Donations and certificate minting functionality may be extended with STX transfers and NFT metadata.

---

## Future Enhancements

- **Donation logic implementation** with STX transfers
- **NFT metadata standardization** for certificates
- **Web interface** for real-time price display and donation interaction
- **Slashing & rewards** for price provider performance
- **Zero-Knowledge proofs** for anonymous donations
