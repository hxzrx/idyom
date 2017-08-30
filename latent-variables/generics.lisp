(cl:in-package #:latent-variables)

(defgeneric latent-state-parameters (variable))
(defgeneric get-category-parameter (category parameter variable))
(defgeneric get-interpretation-parameter (interpretation parameter variable))
(defgeneric get-category (latent-state variable))
(defgeneric get-interpretation (latent-state variable))
(defgeneric get-event-category (event variable))
(defgeneric get-latent-states (category variable))
(defgeneric get-latent-variable-state (variable))
(defgeneric create-interpretation (variable &rest keys &key &allow-other-keys))
(defgeneric create-latent-state (category interpretation variable))

(defgeneric initialise-prior-distribution (categories training-data variable))
