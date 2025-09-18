;; Decentralized Energy Trading Platform Smart Contract
;; Peer-to-peer renewable energy marketplace with automated settlements and community management
;; version: 1.0
;; summary: P2P energy trading platform with renewable verification and smart grid integration
;; description: Complete energy marketplace supporting prosumers, communities, and automated energy trading

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_PRODUCER_NOT_FOUND (err u501))
(define-constant ERR_CONSUMER_NOT_FOUND (err u502))
(define-constant ERR_INSUFFICIENT_ENERGY (err u503))
(define-constant ERR_INVALID_PRICE (err u504))
(define-constant ERR_TRADE_NOT_FOUND (err u505))
(define-constant ERR_SETTLEMENT_FAILED (err u506))
(define-constant ERR_CERTIFICATION_INVALID (err u507))
(define-constant ERR_COMMUNITY_NOT_FOUND (err u508))
(define-constant ERR_GRID_OVERLOAD (err u509))
(define-constant ERR_STORAGE_UNAVAILABLE (err u510))

;; Energy Trading Constants
(define-constant MIN_ENERGY_AMOUNT u1000) ;; Minimum 1 kWh (in Wh)
(define-constant MAX_ENERGY_AMOUNT u1000000000) ;; Maximum 1 GWh
(define-constant MIN_PRICE_PER_KWH u10) ;; Minimum 10 microSTX per kWh
(define-constant MAX_PRICE_PER_KWH u1000000) ;; Maximum 1 STX per kWh
(define-constant RENEWABLE_PREMIUM u20) ;; 20% premium for renewable energy
(define-constant PLATFORM_FEE_RATE u25) ;; 2.5% platform fee
(define-constant SETTLEMENT_WINDOW u144) ;; 24 hours in blocks (10min blocks)
(define-constant COMMUNITY_DISCOUNT u10) ;; 10% discount for community trading

;; Energy Source Types
(define-constant SOURCE_SOLAR u1)
(define-constant SOURCE_WIND u2)
(define-constant SOURCE_HYDRO u3)
(define-constant SOURCE_GEOTHERMAL u4)
(define-constant SOURCE_BIOMASS u5)
(define-constant SOURCE_GRID u6)

;; Trade Status Constants
(define-constant STATUS_OPEN u0)
(define-constant STATUS_MATCHED u1)
(define-constant STATUS_DELIVERED u2)
(define-constant STATUS_SETTLED u3)
(define-constant STATUS_CANCELLED u4)
(define-constant STATUS_DISPUTED u5)

;; Data Variables
(define-data-var producer-counter uint u0)
(define-data-var consumer-counter uint u0)
(define-data-var trade-counter uint u0)
(define-data-var community-counter uint u0)
(define-data-var total-energy-traded uint u0)
(define-data-var total-renewable-energy uint u0)
(define-data-var platform-revenue uint u0)

;; Data Maps

;; Energy Producers (Prosumers)
(define-map energy-producers
  principal
  {
    producer-id: uint,
    name-hash: (buff 32), ;; Encrypted name
    location-hash: (buff 32), ;; Encrypted location
    registered-at: uint,
    total-capacity: uint, ;; Total generation capacity in Watts
    available-capacity: uint, ;; Currently available capacity
    energy-sources: (list 6 uint), ;; Types of energy sources
    renewable-percentage: uint, ;; Percentage of renewable energy
    grid-connected: bool,
    storage-capacity: uint, ;; Battery storage capacity in Wh
    current-storage: uint, ;; Current energy stored
    reputation-score: uint, ;; 0-1000 reliability score
    total-trades: uint,
    successful-deliveries: uint,
    carbon-credits: uint, ;; Earned carbon credits
    certifications: (list 5 (string-ascii 32)) ;; Environmental certifications
  }
)

;; Energy Consumers
(define-map energy-consumers
  principal
  {
    consumer-id: uint,
    name-hash: (buff 32), ;; Encrypted name
    location-hash: (buff 32), ;; Encrypted location
    registered-at: uint,
    average-consumption: uint, ;; Average daily consumption in Wh
    peak-demand: uint, ;; Peak demand in Watts
    renewable-preference: uint, ;; Preference for renewable energy (0-100)
    price-sensitivity: uint, ;; Price sensitivity score (0-100)
    community-member: (optional uint), ;; Community membership
    total-purchases: uint,
    total-spent: uint,
    carbon-footprint: uint, ;; kg CO2 equivalent
    efficiency-score: uint, ;; Energy efficiency rating
    demand-flexibility: bool ;; Can shift demand for grid balancing
  }
)

;; Energy Trade Orders
(define-map energy-trades
  uint ;; Trade ID
  {
    trade-id: uint,
    producer: principal,
    consumer: (optional principal), ;; Matched consumer
    energy-amount: uint, ;; Energy amount in Wh
    price-per-kwh: uint, ;; Price in microSTX per kWh
    total-price: uint, ;; Total trade value
    energy-source: uint, ;; Primary energy source
    renewable-certified: bool,
    delivery-window-start: uint, ;; When energy delivery starts
    delivery-window-end: uint, ;; When energy delivery ends
    created-at: uint,
    matched-at: (optional uint),
    delivered-at: (optional uint),
    settled-at: (optional uint),
    status: uint,
    grid-location: (buff 32), ;; Grid connection point
    quality-rating: (optional uint), ;; Post-delivery quality rating
    carbon-offset: uint, ;; CO2 offset in kg
    community-trade: bool ;; Whether it's within a community
  }
)

;; Energy Communities and Microgrids
(define-map energy-communities
  uint ;; Community ID
  {
    community-id: uint,
    name-hash: (buff 32), ;; Encrypted community name
    admin: principal,
    location-hash: (buff 32), ;; Geographic area
    created-at: uint,
    member-count: uint,
    total-capacity: uint, ;; Combined generation capacity
    total-consumption: uint, ;; Combined consumption
    renewable-percentage: uint,
    energy-independence: uint, ;; Percentage of energy self-sufficiency
    community-battery: uint, ;; Shared battery storage capacity
    grid-connection: bool, ;; Connected to main grid
    trading-policy: (string-ascii 64), ;; Community trading rules
    profit-sharing: uint, ;; Percentage shared with members
    sustainability-score: uint, ;; Environmental impact score
    governance-token: (optional uint) ;; Community governance token
  }
)

;; Real-time Grid Data
(define-map grid-status
  (buff 32) ;; Grid location hash
  {
    location: (buff 32),
    current-load: uint, ;; Current electrical load in Watts
    capacity: uint, ;; Maximum capacity
    frequency: uint, ;; Grid frequency * 1000 (normally ~60000)
    voltage: uint, ;; Voltage level * 1000
    stability-score: uint, ;; Grid stability rating 0-100
    renewable-percentage: uint, ;; Current renewable energy percentage
    carbon-intensity: uint, ;; gCO2/kWh
    last-updated: uint,
    congestion-level: uint, ;; 0-100 congestion indicator
    emergency-status: bool ;; Emergency grid status
  }
)

;; Energy Storage Systems
(define-map energy-storage
  { owner: principal, storage-id: uint }
  {
    storage-id: uint,
    owner: principal,
    storage-type: (string-ascii 32), ;; battery, pumped-hydro, etc.
    capacity: uint, ;; Total storage capacity in Wh
    current-charge: uint, ;; Current energy stored
    charge-rate: uint, ;; Maximum charge rate in Watts
    discharge-rate: uint, ;; Maximum discharge rate in Watts
    efficiency: uint, ;; Round-trip efficiency percentage
    cycle-count: uint, ;; Number of charge/discharge cycles
    degradation-rate: uint, ;; Annual capacity degradation percentage
    availability: bool, ;; Available for grid services
    location-hash: (buff 32), ;; Storage system location
    grid-services: (list 5 (string-ascii 32)) ;; Supported grid services
  }
)

;; Renewable Energy Certificates (RECs)
(define-map renewable-certificates
  uint ;; Certificate ID
  {
    certificate-id: uint,
    producer: principal,
    energy-amount: uint, ;; MWh covered by certificate
    energy-source: uint,
    generation-date: uint,
    location-hash: (buff 32),
    verified-by: (optional principal), ;; Verifying authority
    carbon-offset: uint, ;; CO2 offset in kg
    issued-at: uint,
    expired-at: uint,
    retired: bool, ;; Whether certificate has been retired
    owner: principal, ;; Current certificate owner
    trading-price: uint, ;; Last trading price
    environmental-attributes: (list 5 (string-ascii 32))
  }
)

;; Carbon Credits and Environmental Impact
(define-map carbon-credits
  uint ;; Credit ID
  {
    credit-id: uint,
    producer: principal,
    co2-offset: uint, ;; kg CO2 equivalent
    verification-standard: (string-ascii 32), ;; VCS, Gold Standard, etc.
    project-type: (string-ascii 32), ;; Solar, wind, reforestation, etc.
    vintage-year: uint,
    issued-at: uint,
    verified-at: uint,
    price-per-ton: uint, ;; Price in microSTX per ton CO2
    available-credits: uint,
    retired-credits: uint,
    project-location: (buff 32),
    additional-benefits: (list 3 (string-ascii 32)) ;; Social/environmental co-benefits
  }
)

;; Settlement and Payment Records
(define-map trade-settlements
  uint ;; Settlement ID
  {
    settlement-id: uint,
    trade-id: uint,
    producer: principal,
    consumer: principal,
    energy-delivered: uint, ;; Actual energy delivered
    payment-amount: uint, ;; Total payment in microSTX
    platform-fee: uint, ;; Fee paid to platform
    carbon-credit-value: uint, ;; Value of carbon credits
    settlement-timestamp: uint,
    delivery-confirmation: bool,
    quality-score: uint, ;; Energy quality rating
    dispute-status: bool,
    penalty-applied: uint, ;; Penalties for non-delivery
    bonus-rewards: uint ;; Bonuses for exceptional service
  }
)

;; Public Functions

;; Register as energy producer (prosumer)
(define-public (register-producer (name-hash (buff 32)) (location-hash (buff 32)) (total-capacity uint)
                                 (energy-sources (list 6 uint)) (renewable-percentage uint))
  (let (
    (producer-id (+ (var-get producer-counter) u1))
    (current-block block-height)
  )
    (asserts! (is-none (map-get? energy-producers tx-sender)) ERR_PRODUCER_NOT_FOUND)
    (asserts! (> total-capacity u0) ERR_INVALID_PRICE)
    (asserts! (<= renewable-percentage u100) ERR_CERTIFICATION_INVALID)
    
    ;; Create energy producer profile
    (map-set energy-producers tx-sender {
      producer-id: producer-id,
      name-hash: name-hash,
      location-hash: location-hash,
      registered-at: current-block,
      total-capacity: total-capacity,
      available-capacity: total-capacity,
      energy-sources: energy-sources,
      renewable-percentage: renewable-percentage,
      grid-connected: true,
      storage-capacity: u0,
      current-storage: u0,
      reputation-score: u100, ;; Starting reputation
      total-trades: u0,
      successful-deliveries: u0,
      carbon-credits: u0,
      certifications: (list)
    })
    
    ;; Update producer counter
    (var-set producer-counter producer-id)
    
    (ok producer-id)
  )
)

;; Register as energy consumer
(define-public (register-consumer (name-hash (buff 32)) (location-hash (buff 32)) (average-consumption uint)
                                 (renewable-preference uint))
  (let (
    (consumer-id (+ (var-get consumer-counter) u1))
    (current-block block-height)
  )
    (asserts! (is-none (map-get? energy-consumers tx-sender)) ERR_CONSUMER_NOT_FOUND)
    (asserts! (> average-consumption u0) ERR_INVALID_PRICE)
    (asserts! (<= renewable-preference u100) ERR_CERTIFICATION_INVALID)
    
    ;; Create energy consumer profile
    (map-set energy-consumers tx-sender {
      consumer-id: consumer-id,
      name-hash: name-hash,
      location-hash: location-hash,
      registered-at: current-block,
      average-consumption: average-consumption,
      peak-demand: (* average-consumption u2), ;; Estimate peak as 2x average
      renewable-preference: renewable-preference,
      price-sensitivity: u50, ;; Default moderate price sensitivity
      community-member: none,
      total-purchases: u0,
      total-spent: u0,
      carbon-footprint: u0,
      efficiency-score: u50, ;; Default efficiency score
      demand-flexibility: false
    })
    
    ;; Update consumer counter
    (var-set consumer-counter consumer-id)
    
    (ok consumer-id)
  )
)

;; Create energy sell order
(define-public (create-sell-order (energy-amount uint) (price-per-kwh uint) (energy-source uint)
                                 (delivery-window-start uint) (delivery-window-end uint) (renewable-certified bool))
  (let (
    (producer (unwrap! (map-get? energy-producers tx-sender) ERR_PRODUCER_NOT_FOUND))
    (trade-id (+ (var-get trade-counter) u1))
    (current-block block-height)
    (total-price (* energy-amount (/ price-per-kwh u1000))) ;; Convert from per-kWh to per-Wh
  )
    (asserts! (>= energy-amount MIN_ENERGY_AMOUNT) ERR_INSUFFICIENT_ENERGY)
    (asserts! (<= energy-amount MAX_ENERGY_AMOUNT) ERR_INSUFFICIENT_ENERGY)
    (asserts! (>= price-per-kwh MIN_PRICE_PER_KWH) ERR_INVALID_PRICE)
    (asserts! (<= price-per-kwh MAX_PRICE_PER_KWH) ERR_INVALID_PRICE)
    (asserts! (<= energy-amount (get available-capacity producer)) ERR_INSUFFICIENT_ENERGY)
    (asserts! (< delivery-window-start delivery-window-end) ERR_INVALID_PRICE)
    
    ;; Create energy trade order
    (map-set energy-trades trade-id {
      trade-id: trade-id,
      producer: tx-sender,
      consumer: none,
      energy-amount: energy-amount,
      price-per-kwh: price-per-kwh,
      total-price: total-price,
      energy-source: energy-source,
      renewable-certified: renewable-certified,
      delivery-window-start: delivery-window-start,
      delivery-window-end: delivery-window-end,
      created-at: current-block,
      matched-at: none,
      delivered-at: none,
      settled-at: none,
      status: STATUS_OPEN,
      grid-location: (get location-hash producer),
      quality-rating: none,
      carbon-offset: (if renewable-certified (* energy-amount u500) u0), ;; 0.5kg CO2/kWh offset
      community-trade: false
    })
    
    ;; Reserve producer capacity
    (map-set energy-producers tx-sender (merge producer {
      available-capacity: (- (get available-capacity producer) energy-amount)
    }))
    
    ;; Update trade counter
    (var-set trade-counter trade-id)
    
    (ok trade-id)
  )
)

;; Match and execute energy trade
(define-public (buy-energy (trade-id uint) (consumer-location (buff 32)))
  (let (
    (trade (unwrap! (map-get? energy-trades trade-id) ERR_TRADE_NOT_FOUND))
    (consumer (unwrap! (map-get? energy-consumers tx-sender) ERR_CONSUMER_NOT_FOUND))
    (producer (unwrap! (map-get? energy-producers (get producer trade)) ERR_PRODUCER_NOT_FOUND))
    (current-block block-height)
    (platform-fee (/ (* (get total-price trade) PLATFORM_FEE_RATE) u1000))
    (producer-payment (- (get total-price trade) platform-fee))
  )
    (asserts! (is-eq (get status trade) STATUS_OPEN) ERR_TRADE_NOT_FOUND)
    (asserts! (>= current-block (get delivery-window-start trade)) ERR_SETTLEMENT_FAILED)
    (asserts! (<= current-block (get delivery-window-end trade)) ERR_SETTLEMENT_FAILED)
    
    ;; Transfer payment from consumer to producer (minus platform fee)
    (try! (stx-transfer? producer-payment tx-sender (get producer trade)))
    ;; Transfer platform fee to contract
    (try! (stx-transfer? platform-fee tx-sender (as-contract tx-sender)))
    
    ;; Update trade with consumer match
    (map-set energy-trades trade-id (merge trade {
      consumer: (some tx-sender),
      matched-at: (some current-block),
      status: STATUS_MATCHED,
      community-trade: (is-community-trade (get location-hash producer) consumer-location)
    }))
    
    ;; Update consumer statistics
    (map-set energy-consumers tx-sender (merge consumer {
      total-purchases: (+ (get total-purchases consumer) u1),
      total-spent: (+ (get total-spent consumer) (get total-price trade)),
      carbon-footprint: (if (get renewable-certified trade)
                          (get carbon-footprint consumer)
                          (+ (get carbon-footprint consumer) (get carbon-offset trade)))
    }))
    
    ;; Update producer statistics
    (map-set energy-producers (get producer trade) (merge producer {
      total-trades: (+ (get total-trades producer) u1)
    }))
    
    ;; Update global statistics
    (var-set total-energy-traded (+ (var-get total-energy-traded) (get energy-amount trade)))
    (var-set platform-revenue (+ (var-get platform-revenue) platform-fee))
    (if (get renewable-certified trade)
      (var-set total-renewable-energy (+ (var-get total-renewable-energy) (get energy-amount trade)))
      true
    )
    
    (ok trade-id)
  )
)

;; Confirm energy delivery
(define-public (confirm-delivery (trade-id uint) (actual-energy-delivered uint) (quality-rating uint))
  (let (
    (trade (unwrap! (map-get? energy-trades trade-id) ERR_TRADE_NOT_FOUND))
    (producer (unwrap! (map-get? energy-producers tx-sender) ERR_PRODUCER_NOT_FOUND))
    (current-block block-height)
  )
    (asserts! (is-eq (get producer trade) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status trade) STATUS_MATCHED) ERR_SETTLEMENT_FAILED)
    (asserts! (<= quality-rating u100) ERR_INVALID_PRICE)
    
    ;; Update trade with delivery confirmation
    (map-set energy-trades trade-id (merge trade {
      delivered-at: (some current-block),
      status: STATUS_DELIVERED,
      quality-rating: (some quality-rating)
    }))
    
    ;; Update producer reputation based on delivery performance
    (let ((delivery-score (if (>= actual-energy-delivered (get energy-amount trade)) u10 u5)))
      (map-set energy-producers tx-sender (merge producer {
        successful-deliveries: (+ (get successful-deliveries producer) u1),
        reputation-score: (+ (get reputation-score producer) delivery-score),
        available-capacity: (+ (get available-capacity producer) (get energy-amount trade))
      }))
    )
    
    (ok true)
  )
)

;; Create energy community
(define-public (create-energy-community (name-hash (buff 32)) (location-hash (buff 32)) (trading-policy (string-ascii 64)))
  (let (
    (community-id (+ (var-get community-counter) u1))
    (current-block block-height)
  )
    ;; Create energy community
    (map-set energy-communities community-id {
      community-id: community-id,
      name-hash: name-hash,
      admin: tx-sender,
      location-hash: location-hash,
      created-at: current-block,
      member-count: u1,
      total-capacity: u0,
      total-consumption: u0,
      renewable-percentage: u0,
      energy-independence: u0,
      community-battery: u0,
      grid-connection: true,
      trading-policy: trading-policy,
      profit-sharing: u50, ;; Default 50% profit sharing
      sustainability-score: u50,
      governance-token: none
    })
    
    ;; Update community counter
    (var-set community-counter community-id)
    
    (ok community-id)
  )
)

;; Join energy community
(define-public (join-energy-community (community-id uint))
  (let (
    (community (unwrap! (map-get? energy-communities community-id) ERR_COMMUNITY_NOT_FOUND))
    (consumer (map-get? energy-consumers tx-sender))
    (producer (map-get? energy-producers tx-sender))
  )
    (asserts! (or (is-some consumer) (is-some producer)) ERR_CONSUMER_NOT_FOUND)
    
    ;; Update community member count
    (map-set energy-communities community-id (merge community {
      member-count: (+ (get member-count community) u1)
    }))
    
    ;; Update consumer community membership if consumer
    (if (is-some consumer)
      (map-set energy-consumers tx-sender (merge (unwrap-panic consumer) {
        community-member: (some community-id)
      }))
      true
    )
    
    (ok true)
  )
)

;; Add energy storage system
(define-public (add-energy-storage (storage-type (string-ascii 32)) (capacity uint) (efficiency uint))
  (let (
    (producer (unwrap! (map-get? energy-producers tx-sender) ERR_PRODUCER_NOT_FOUND))
    (storage-id u1) ;; Simplified - would be incremental in full implementation
  )
    (asserts! (> capacity u0) ERR_INVALID_PRICE)
    (asserts! (<= efficiency u100) ERR_INVALID_PRICE)
    
    ;; Create energy storage entry
    (map-set energy-storage { owner: tx-sender, storage-id: storage-id } {
      storage-id: storage-id,
      owner: tx-sender,
      storage-type: storage-type,
      capacity: capacity,
      current-charge: u0,
      charge-rate: (/ capacity u4), ;; Assume 4-hour charge time
      discharge-rate: (/ capacity u4),
      efficiency: efficiency,
      cycle-count: u0,
      degradation-rate: u2, ;; 2% annual degradation
      availability: true,
      location-hash: (get location-hash producer),
      grid-services: (list "frequency-regulation" "load-balancing")
    })
    
    ;; Update producer with storage capacity
    (map-set energy-producers tx-sender (merge producer {
      storage-capacity: (+ (get storage-capacity producer) capacity)
    }))
    
    (ok storage-id)
  )
)

;; Private Functions

;; Check if trade is within community (simplified distance check)
(define-private (is-community-trade (producer-location (buff 32)) (consumer-location (buff 32)))
  ;; Simplified community detection - in production would use actual geolocation
  (is-eq (unwrap-panic (slice? producer-location u0 u16)) (unwrap-panic (slice? consumer-location u0 u16)))
)

;; Calculate renewable premium pricing
(define-private (calculate-renewable-premium (base-price uint) (renewable-certified bool))
  (if renewable-certified
    (+ base-price (/ (* base-price RENEWABLE_PREMIUM) u100))
    base-price
  )
)

;; Calculate grid congestion factor
(define-private (calculate-congestion-multiplier (grid-location (buff 32)))
  (match (map-get? grid-status grid-location)
    grid-data
    (let ((congestion (get congestion-level grid-data)))
      (if (> congestion u80) u120 ;; 20% increase for high congestion
          (if (< congestion u20) u90  ;; 10% decrease for low congestion
              u100))) ;; No change for normal congestion
    u100 ;; Default if no grid data available
  )
)

;; Update producer reputation based on performance
(define-private (update-producer-reputation (producer principal) (performance-score uint))
  (match (map-get? energy-producers producer)
    producer-data
    (let (
      (current-rep (get reputation-score producer-data))
      (new-rep (/ (+ (* current-rep u9) performance-score) u10)) ;; Weighted average
    )
      (map-set energy-producers producer (merge producer-data {
        reputation-score: new-rep
      }))
      new-rep
    )
    u0
  )
)

;; Calculate carbon offset for energy trade
(define-private (calculate-carbon-offset (energy-amount uint) (energy-source uint) (renewable bool))
  (if renewable
    u0 ;; Renewable energy has no carbon footprint
    (if (is-eq energy-source SOURCE_GRID)
      (* energy-amount u600) ;; 0.6 kg CO2/kWh for grid average
      (if (is-eq energy-source SOURCE_SOLAR)
        u0
        (if (is-eq energy-source SOURCE_WIND)
          u0
          (if (is-eq energy-source SOURCE_HYDRO)
            u0
            (if (is-eq energy-source SOURCE_GEOTHERMAL)
              u0
              (if (is-eq energy-source SOURCE_BIOMASS)
                (* energy-amount u50) ;; 0.05 kg CO2/kWh for biomass
                (* energy-amount u500) ;; Default 0.5 kg CO2/kWh
              )
            )
          )
        )
      )
    )
  )
)

;; Read-Only Functions

;; Get producer profile
(define-read-only (get-producer-profile (producer principal))
  (map-get? energy-producers producer)
)

;; Get consumer profile
(define-read-only (get-consumer-profile (consumer principal))
  (map-get? energy-consumers consumer)
)

;; Get energy trade details
(define-read-only (get-trade-details (trade-id uint))
  (map-get? energy-trades trade-id)
)

;; Get energy community information
(define-read-only (get-community-info (community-id uint))
  (map-get? energy-communities community-id)
)

;; Get grid status for location
(define-read-only (get-grid-status (location (buff 32)))
  (map-get? grid-status location)
)

;; Get platform statistics
(define-read-only (get-platform-stats)
  (ok {
    total-producers: (var-get producer-counter),
    total-consumers: (var-get consumer-counter),
    total-trades: (var-get trade-counter),
    total-communities: (var-get community-counter),
    total-energy-traded: (var-get total-energy-traded),
    renewable-energy-percentage: (if (> (var-get total-energy-traded) u0)
                                   (/ (* (var-get total-renewable-energy) u100)
                                      (var-get total-energy-traded))
                                   u0),
    platform-revenue: (var-get platform-revenue)
  })
)

;; Get renewable certificate details
(define-read-only (get-renewable-certificate (certificate-id uint))
  (map-get? renewable-certificates certificate-id)
)

;; Calculate trade settlement amount
(define-read-only (calculate-settlement-amount (trade-id uint))
  (match (map-get? energy-trades trade-id)
    trade
    (let (
      (base-amount (get total-price trade))
      (platform-fee (/ (* base-amount PLATFORM_FEE_RATE) u1000))
      (net-amount (- base-amount platform-fee))
    )
      (ok {
        total-price: base-amount,
        platform-fee: platform-fee,
        producer-payment: net-amount,
        carbon-credit-value: (get carbon-offset trade)
      })
    )
    (err ERR_TRADE_NOT_FOUND)
  )
)

;; Check energy storage availability
(define-read-only (get-storage-info (owner principal) (storage-id uint))
  (map-get? energy-storage { owner: owner, storage-id: storage-id })
)

;; Get carbon credit information
(define-read-only (get-carbon-credit-info (credit-id uint))
  (map-get? carbon-credits credit-id)
)
