;;;; ======================================================================
;;;; File:       main.lisp
;;;; Author:     Marcus Pearce <marcus.pearce@eecs.qmul.ac.uk>
;;;; Created:    <2010-11-01 15:19:57 marcusp>
;;;; Time-stamp: <2014-01-28 09:49:54 marcusp>
;;;; ======================================================================

(cl:in-package #:idyom)

(defvar *cpitch-viewpoints*
  '(;; Chromatic pitch
    :cpitch       ; chromatic pitch (midi pitch number)
    :cpitch-class ; octave equivalent pitch class (chroma)
    :tessitura    ; 3 values: whether a note is between 66 (G#4) and 74 (D5), above, or below this range
    ;; Pitch interval
    :cpint        ; pitch interval in semitones 
    :cpint-size   ; absolute size of pitch interval
    :cpcint       ; pitch interval class (mod 12) 
    :cpcint-size  ; absolute size of pitch interval class
    ;; Contour
    :contour      ; contour (-1, 0, 1)
    :newcontour   ; boolean: whether or not contour is the same as the previous contour
    ;; Tonality
    :cpintfip     ; pitch interval from the first note in the piece
    :cpintfref    ; chromatic scale degree
    :inscale      ; boolean: whether or not the note is in the scale
    ))

(defvar *cpitch-viewpoints-short*
  '(:cpitch :cpitch-class :cpint :cpint-size :contour :newcontour))

(defvar *bioi-viewpoints*
  '(:bioi           ; inter-onset interval
    :bioi-ratio     ; ratio between consecutive inter-onset intervals
    :bioi-contour   ; contour between consecutive inter-onset intervals
    ))


;;; IDyOM top-level
;;;
(defun idyom (dataset-id target-viewpoints source-viewpoints
              &key 
	      ;; Dataset IDs for LTM pretraining
              pretraining-ids 
	      ;; Resampling
	      (k 10) ; Number of cross-validation folds (:full = LOO CV)
              resampling-indices ; Evaluate only certain resampling subsets
	      ;; Model options
	      (models :both+)
	      (ltmo mvs::*ltm-params*) (stmo mvs::*stm-params*)
              ;; Viewpoint selection 
	      (basis :default)
              (dp nil) (max-links 2)
	      (vp-white '(:any))
	      (vp-black nil)
              ;; Output 
              (detail 3) (output-path nil))
  "IDyOM top level: computes information profiles for basic
   target-viewpoints over a dataset (dataset-id), using a set of
   source-viewpoints, which can be specified or selected
   automatically.  The LTM is optionally pretrained on multiple
   datasets (pretraining-ids) and/or other members of the target
   dataset using k-fold cross validation (AKA resampling)."
  ;; Select source viewpoints, if requested
  (when (eq source-viewpoints :select)
    (format t "~&Selecting viewpoints for the ~A model on dataset ~A predicting viewpoints ~A.~%" 
            models dataset-id target-viewpoints)
    (let* (; Generate candidate viewpoint systems
	   (sel-basis (find-selection-basis target-viewpoints basis))
	   (viewpoint-systems (generate-viewpoint-systems sel-basis max-links vp-white vp-black))
           ; Select viewpoint system
	   (selected (viewpoint-selection:dataset-viewpoint-selection
                      dataset-id target-viewpoints viewpoint-systems
                      :dp dp :pretraining-ids pretraining-ids
                      :k k :resampling-indices resampling-indices
                      :models models :ltmo ltmo :stmo stmo)))
      (setf source-viewpoints selected)))
  ;; Derive target viewpoint IC profile from source viewpoints
  (multiple-value-bind (predictions filename)
      (resampling:idyom-resample dataset-id target-viewpoints source-viewpoints
                                     :pretraining-ids pretraining-ids
				     :k k :resampling-indices resampling-indices
                                     :models models :ltmo ltmo :stmo stmo)
    (when output-path
      (resampling:format-information-content predictions (concatenate 'string output-path "/" filename) dataset-id detail))
    (resampling:output-information-content predictions detail)))


(defun find-selection-basis (targets basis)
  "Determine which viewpoints are to be used in selection process"
  (cond (; Auto mode: use all views derived from target viewpoints. 
	 (eq basis :auto) 
	 (let ((vps (viewpoints:predictors targets)))
	   (if (null vps)
	       (error "Auto viewpoint selection: no defined viewpoints found that might predict target viewpoints ~S" targets)
	       vps)))
	;; Default mode: use conservative default viewpoints for this target
	((eq basis :default) *cpitch-viewpoints-short*)
	;; Predefined viewpoint sets
	((eq basis :ioi-views) *bioi-viewpoints*)
	((eq basis :pitch-viewsA) *cpitch-viewpoints*)
	((eq basis :pitch-viewsB) *cpitch-viewpoints-short*)
	;; Else use supplied viewpoints
	(t basis)))

;;
;; Each candidate viewpoint must match at least viewpoint patterns on
;; the whitelist, and none on the black.
;;
;; E.g. (generate-viewpoint-systems '(:cpitch :cpint :bioi :bioi-ratio) 3 '(:pitch (:pitch :pitch :ioi)) nil)
;; => (:CPITCH :CPINT (:CPITCH :CPINT :BIOI-RATIO) (:CPITCH :CPINT :BIOI))
;;
(defun generate-viewpoint-systems (basis-vps max-links white black)
      (format t "Generating candidate viewpoints from: ~A~%Max. links ~A, whitelist ~A, blacklist ~A~%" basis-vps max-links white black)
      (let* ((links (remove-if #'(lambda (x) (or (null x) (< (length x) 2) 
						 (> (length x) max-links)))
			       (utils:powerset basis-vps)))
	     (slinks (sort links #'(lambda (x y) (< (length x) (length y)))))
	     (candidates (append basis-vps slinks))
	     (filtered (remove-if-not #'(lambda (x) (and (match-vp-patterns x white)
						       (not (match-vp-patterns x black))))
				    candidates)))
	(progn (format t "Candidate viewpoints: ~A~%" filtered)
	       filtered)))

(defun match-vp-patterns (vp patterns)
  "Does the viewpoint match one of the patterns?"
  (if (or (not (listp patterns))
	  (null patterns))
      nil
      (or (match-vp-pattern vp (car patterns))
	  (match-vp-patterns vp (cdr patterns)))))

(defun match-vp-pattern (vp pattern)
  "Does the viewpoint match this pattern?"
  (or
   ;; ATOMIC PATTERNS
   ;;
   ;; Match any viewpoint
   (eq pattern :any)
   ;; Pitch viewpoint
   (and (eq pattern :pitch) (member vp *cpitch-viewpoints*))
   ;; IOI viewpoint
   (and (eq pattern :ioi) (member vp *bioi-viewpoints*))
   ;;
   ;; COMPOUND PATTERNS
   ;;
   (and (listp pattern)
	(if (eq (car pattern) :or)
	    ;; List of ground viewpoints
	    (member vp (cdr pattern))
	    ;; Match linked viewpoint
	    (and (listp vp)
		 (eq (length vp) (length pattern))
		 (reduce #'(lambda (a b) (and a b))
			 (mapcar #'match-vp-pattern vp pattern)))))))
		 




;;; 170: unmeasured prelude
;;; 30: 120 hymns
;;; 130: flute corpus
;;; 250: Persian melodies
;;
;; (defun main (dataset-id pretraining-ids k dp basic-viewpoints viewpoints)
;;   (dolist (models '(:stm :ltm :ltm+ :both :both+))
;;     (format t "~&Dataset: ~A; Model: ~A~%" dataset-id models)
;;     (viewpoint-selection:dataset-viewpoint-selection dataset-id basic-viewpoints viewpoints 
;;                                                      :dp dp
;;                                                      :models models
;;                                                      :pretraining-ids pretraining-ids
;;                                                      :k k)))
