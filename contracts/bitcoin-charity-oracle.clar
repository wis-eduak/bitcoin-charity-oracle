;; Title: Bitcoin Charity Oracle (BCO)
;;
;; Summary:
;; A decentralized price oracle and charitable donation platform built for the Stacks ecosystem,
;; enabling transparent, Bitcoin-denominated charitable giving with real-time price feeds.
;;
;; Description:
;; This smart contract combines a robust multi-provider price oracle with a charitable donation
;; platform. It ensures reliable price data through multiple validators while enabling
;; transparent and verifiable charitable donations. Each donation is commemorated with
;; a unique NFT certificate, providing donors with proof of their contribution.
;;
;; Features:
;; - Decentralized price oracle with multiple providers
;; - Charitable donation platform with cause management
;; - NFT certificates for donation verification
;; - Real-time price validation and aggregation
;; - Transparent fund tracking and distribution
;;
;; Architecture:
;; The contract is structured into four main components:
;; 1. Oracle Management - Price provider coordination and validation
;; 2. Donation Platform - Cause creation and donation handling
;; 3. NFT Certificates - Proof of donation through non-fungible tokens
;; 4. Price Aggregation - Secure price feed calculation and validation

;; Constants - Contract ownership & error codes
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_STALE_PRICE (err u101))
(define-constant ERR_INSUFFICIENT_PROVIDERS (err u102))
(define-constant ERR_PRICE_TOO_LOW (err u103))
(define-constant ERR_PRICE_TOO_HIGH (err u104))
(define-constant ERR_PRICE_DEVIATION (err u105))
(define-constant ERR_ZERO_PRICE (err u106))
(define-constant ERR_INVALID_BLOCK (err u107))
(define-constant ERR_PROVIDER_EXISTS (err u108))

;; Configuration - Oracle parameters
;;
(define-constant PRICE_PRECISION u100000000)  ;; 8 decimal places
(define-constant MAX_PRICE_AGE u900)          ;; 15 minutes in blocks
(define-constant MIN_PRICE_PROVIDERS u3)      ;; Minimum required price providers
(define-constant MAX_PRICE_PROVIDERS u10)     ;; Maximum allowed price providers
(define-constant MAX_PRICE_DEVIATION u200)    ;; 20% maximum deviation from median
(define-constant MIN_VALID_PRICE u100000)     ;; Minimum valid price
(define-constant MAX_VALID_PRICE u1000000000) ;; Maximum valid price

;; Data Variables - Oracle state
;;
(define-data-var current-price uint u0)
(define-data-var last-update-block uint u0)
(define-data-var active-providers uint u0)
(define-data-var next-cause-id uint u1)
(define-data-var next-certificate-id uint u1)

;; Error Message Handling
;;
(define-map error-messages (response uint uint) (string-ascii 64))

;; Initialize error messages
(map-insert error-messages ERR_NOT_AUTHORIZED "Not authorized to perform this action")
(map-insert error-messages ERR_STALE_PRICE "Price data is stale")

(map-insert error-messages ERR_INSUFFICIENT_PROVIDERS "Insufficient number of price providers")

(map-insert error-messages ERR_PRICE_TOO_LOW "Price is below minimum threshold")

(map-insert error-messages ERR_PRICE_TOO_HIGH "Price is above maximum threshold")

(map-insert error-messages ERR_PRICE_DEVIATION "Price deviates too much from median")

(map-insert error-messages ERR_ZERO_PRICE "Price cannot be zero")

(map-insert error-messages ERR_INVALID_BLOCK "Invalid block height provided")

(map-insert error-messages ERR_PROVIDER_EXISTS "Provider already exists")

;; Maps - Oracle data storage
;;
(define-map price-providers principal bool)
(define-map provider-prices principal uint)
(define-map provider-last-update principal uint)
(define-map active-provider-list uint principal)
(define-map historical-prices uint {price: uint, block: uint})

;; Maps - Donation platform data storage
;;
(define-map donations 
  (tuple (donor principal) (cause-id uint)) 
  (tuple (amount uint) (timestamp uint))
)

(define-map causes 
  (tuple (cause-id uint)) 
  (tuple (name (string-ascii 64)) (target uint) (raised uint) (recipient principal))
)

;; NFT - Donation certificates
;;
(define-non-fungible-token donation-certificate uint)

;; ==========================================
;; PRIVATE FUNCTIONS - ORACLE
;; ==========================================

(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-authorized-provider (provider principal))
  (default-to false (map-get? price-providers provider))
)

(define-private (get-provider-price (provider principal))
  (default-to u0 (map-get? provider-prices provider))
)

(define-private (collect-provider-prices (index uint) (prices (list 100 uint)))
  (match (map-get? active-provider-list index)
    provider (let ((price (get-provider-price provider)))
               (if (> price u0)
                 (unwrap! (as-max-len? (append prices price) u100) prices)
                 prices))
    prices)
)

(define-private (get-all-provider-prices)
  (fold collect-provider-prices
    (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9)
    (list))
)