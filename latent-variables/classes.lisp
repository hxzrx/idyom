(cl:in-package #:latent-variables)

(defclass latent-variable ()
  ((states :reader latent-states
	   :initarg states)
   (prior-distribution :accessor prior-distribution
		       :initarg :prior-distribution)
   (interpretation-parameters :accessor interpretation-parameters
			      :initarg :interpretation-parameters
			      :type list)
   (category-parameters :accessor category-parameters
			:initarg :category-parameters
			:type list)))

(defclass linked (latent-variable)
  ((links :accessor latent-variable-links
	  :initarg :links
	  :type list))
  (:documentation ""))
