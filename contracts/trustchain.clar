;; Define data map for vaults
(define-map vaults principal
  {
    beneficiary: principal,
    unlock-block: uint,
    approved-guardians: (list 5 principal),
    guardian-approvals: (list 5 principal),
    is-unlocked: bool
  }
)

;; Constants
(define-constant inactivity-threshold u10000) ;; ~70 days at 10min/block

;; Helper function to check if a principal is in a list of principals
(define-read-only (contains (xs (list 5 principal)) (item principal))
  (is-some (index-of xs item))
)

;; Create a vault with inheritance rules
(define-public (create-vault (beneficiary principal) (guardians (list 5 principal)))
  (ok (map-set vaults tx-sender {
    beneficiary: beneficiary,
    unlock-block: (+ u1 inactivity-threshold),
    approved-guardians: guardians,
    guardian-approvals: (list),
    is-unlocked: false
  }))
)

;; Guardian approval for vault unlock
(define-public (approve-unlock (owner principal))
  (let ((vault (map-get? vaults owner)))
    (match vault some-vault
      (begin
        (asserts! (is-eq false (get is-unlocked some-vault)) (err u101))
        (asserts! (contains (get approved-guardians some-vault) tx-sender) (err u102))
        (let ((approvals (get guardian-approvals some-vault)))
          (asserts! (not (contains approvals tx-sender)) (err u103))
          (ok (map-set vaults owner (merge some-vault {
            guardian-approvals: (unwrap-panic (as-max-len? (append approvals tx-sender) u5))
          })))
        )
      )
      (err u100)
    )
  )
)

;; Check if vault can be unlocked (majority guardian + inactivity)
(define-public (unlock-vault (owner principal))
  (let ((vault (map-get? vaults owner)))
    (match vault some-vault
      (begin
        (asserts! (is-eq false (get is-unlocked some-vault)) (err u104))
        (let (
          (approvals (get guardian-approvals some-vault))
          (approved-guardians (get approved-guardians some-vault))
          (majority (>= (len approvals) (/ (+ (len approved-guardians) u1) u2)))
        )
          (asserts! majority (err u105))
          (asserts! (>= burn-block-height (get unlock-block some-vault)) (err u106))
          (ok (map-set vaults owner (merge some-vault { is-unlocked: true })))
        )
      )
      (err u100)
    )
  )
)

;; Claim assets after vault unlocked
(define-public (claim-assets (owner principal))
  (let ((vault (map-get? vaults owner)))
    (match vault some-vault
      (begin
        (asserts! (is-eq tx-sender (get beneficiary some-vault)) (err u107))
        (asserts! (is-eq true (get is-unlocked some-vault)) (err u108))
        ;; Transfer assets logic can be extended here
        (ok (map-delete vaults owner))
      )
      (err u100)
    )
  )
)

;; Read-only: Check vault status
(define-read-only (get-vault (owner principal))
  (map-get? vaults owner)
)
