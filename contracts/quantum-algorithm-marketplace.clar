;; Quantum Algorithm Marketplace Contract

(define-data-var next-algorithm-id uint u0)

(define-map quantum-algorithms
  { algorithm-id: uint }
  {
    owner: principal,
    name: (string-ascii 100),
    description: (string-utf8 500),
    price: uint,
    license: (string-ascii 20)
  }
)

(define-map algorithm-purchases
  { algorithm-id: uint, buyer: principal }
  { purchased: bool }
)

(define-public (list-algorithm (name (string-ascii 100)) (description (string-utf8 500)) (price uint) (license (string-ascii 20)))
  (let
    ((algorithm-id (+ (var-get next-algorithm-id) u1)))
    (var-set next-algorithm-id algorithm-id)
    (ok (map-set quantum-algorithms
      { algorithm-id: algorithm-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        price: price,
        license: license
      }
    ))
  )
)

(define-public (purchase-algorithm (algorithm-id uint))
  (let
    ((algorithm (unwrap! (map-get? quantum-algorithms { algorithm-id: algorithm-id }) (err u404))))
    (asserts! (is-eq (get purchased (default-to { purchased: false } (map-get? algorithm-purchases { algorithm-id: algorithm-id, buyer: tx-sender }))) false) (err u403))
    (try! (stx-transfer? (get price algorithm) tx-sender (get owner algorithm)))
    (ok (map-set algorithm-purchases
      { algorithm-id: algorithm-id, buyer: tx-sender }
      { purchased: true }
    ))
  )
)

(define-read-only (get-algorithm (algorithm-id uint))
  (map-get? quantum-algorithms { algorithm-id: algorithm-id })
)

(define-read-only (has-purchased-algorithm (algorithm-id uint) (buyer principal))
  (default-to
    false
    (get purchased (map-get? algorithm-purchases { algorithm-id: algorithm-id, buyer: buyer }))
  )
)

