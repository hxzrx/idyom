;;; =======================================================================
;;;; File:       study-1.lisp
;;;; Author:     Peter Harrison <p.m.c.harrison@qmul.ac.uk>
;;;; Created:    <2017-05-15 13:37:26 peter>                          
;;;; Time-stamp: <2017-07-26 16:31:58 peter>                           
;;;; =======================================================================

;;;; Description ==========================================================
;;;; ======================================================================
;;;;
;;;; Provides utility functions for Peter's study on harmony representations.

(cl:in-package #:pmch-s1)

;;;; Top-level call

(defun run-study-1 ()
  ;; Set paths
  (let ((output-dir
	 (cond ((member :os-macosx cl-user::*features*)
		"/Users/peter/Dropbox/Academic/projects/idyom/studies/HarmonyRepresentations/data-raw/data-6/data/")
	       ((member :marcus-pc cl-user::*features*)
		"/home/pharrison/HarmonyRepresentations/data-6/")
	       (t "/home/peter/Dropbox/Academic/projects/idyom/studies/HarmonyRepresentations/data-raw/data-6/data/"))))
  ;;;; Calculate alphabet sizes
  (viewpoints:get-alphabet-sizes
   *harmony-viewpoints* '(1)
   :output-path (merge-pathnames "alphabets/classical_alphabets.csv" output-dir)
   :texture :harmony
   :harmonic-reduction :regular-harmonic-rhythm
   :remove-repeated-chords t)
  (viewpoints:get-alphabet-sizes
   *harmony-viewpoints* '(2)
   :output-path (merge-pathnames "alphabets/popular_alphabets.csv" output-dir)
   :texture :harmony
   :harmonic-reduction :none
   :remove-repeated-chords t)
  (viewpoints:get-alphabet-sizes
   *harmony-viewpoints* '(3)
   :output-path (merge-pathnames "alphabets/jazz_alphabets.csv" output-dir)
   :texture :harmony
   :harmonic-reduction :none
   :remove-repeated-chords t)
  ;;;; Save viewpoint quantiles
  ;; Classical
  (save-viewpoint-quantiles 1
			    :output-path output-dir
			    :reduce-harmony t
			    :remove-repeated-chords t
			    :num-quantiles 12)
  ;; Popular
  (save-viewpoint-quantiles 2
			    :output-path output-dir
			    :reduce-harmony nil
			    :remove-repeated-chords t
			    :num-quantiles 12)
  ;; Jazz
  (save-viewpoint-quantiles 3
			    :output-path output-dir
			    :reduce-harmony nil
			    :remove-repeated-chords t
			    :num-quantiles 12)
  ;;;; Save transition probabilities
  ;;;  0th-order (note: we don't quantise for this)
  ;;   Classical
  (analyse-tps-all-viewpoints 1
			      :output-path output-dir
			      :reduce-harmony t
			      :remove-repeated-chords t
			      :n 0 :num-quantiles nil)
  ;;   Popular
  (analyse-tps-all-viewpoints 2
			      :output-path output-dir
			      :reduce-harmony nil
			      :remove-repeated-chords t
			      :n 0 :num-quantiles nil)
  ;;   Jazz
  (analyse-tps-all-viewpoints 3
			      :output-path output-dir
			      :reduce-harmony nil
			      :remove-repeated-chords t
			      :n 0 :num-quantiles nil)
  ;;;  1st-order
  ;;   Classical
  (analyse-tps-all-viewpoints 1
			      :output-path output-dir
			      :reduce-harmony t
			      :remove-repeated-chords t
			      :n 1 :num-quantiles 12)
  ;;   Popular
  (analyse-tps-all-viewpoints 2
			      :output-path output-dir
			      :reduce-harmony nil
			      :remove-repeated-chords t
			      :n 1 :num-quantiles 12)
  ;;   Jazz
  (analyse-tps-all-viewpoints 3
			      :output-path output-dir
			      :reduce-harmony nil
			      :remove-repeated-chords t
			      :n 1 :num-quantiles 12)
  ;;;; Analyse test length
  ;; Classical (1022 pieces in corpus, max 987 in training set with 30-fold CV)
  (loop for ts-size in '(987 8 512 256 16 128 32 64 4 2 1)
     do (pmch-s1:analyse-all-viewpoints 
	 1 nil
	 :reduce-harmony t
	 :k 30
	 :training-set-size ts-size
	 :output-path output-dir
	 :remove-repeated-chords t))
  ;; Pop (739 pieces in corpus, max 714 in training set with 30-fold CV)
  (loop for ts-size in '(714 8 512 256 16 128 32 64 4 2 1)
     do (pmch-s1:analyse-all-viewpoints 
	 2 nil
	 :k 30
	 :training-set-size ts-size
	 :output-path output-dir
	 :remove-repeated-chords t))
  ;; Jazz (1186 pieces in corpus, max 714 in training set with 30-fold CV)
  (loop for ts-size in '(1024 8 512 256 16 128 32 64 4 2 1)
     do (pmch-s1:analyse-all-viewpoints 
	 3 nil
	 :k 30
	 :training-set-size ts-size
	 :output-path output-dir
	 :remove-repeated-chords t))
  ;;;; Analyse generalisation
  ;; Train on classical, test on jazz
  (pmch-s1:analyse-all-viewpoints 3 '(1)
				  :reduce-harmony nil
				  :reduce-harmony-pretraining t
				  :k 1
				  :output-path output-dir
				  :remove-repeated-chords t)
  ;; Train on pop, test on jazz
  (pmch-s1:analyse-all-viewpoints 3 '(2)
				  :reduce-harmony nil
				  :reduce-harmony-pretraining nil
				  :k 1
				  :output-path output-dir
				  :remove-repeated-chords t)
  ;; Train on classical, test on pop
  (pmch-s1:analyse-all-viewpoints 2 '(1)
				  :reduce-harmony nil
				  :reduce-harmony-pretraining t
				  :k 1
				  :output-path output-dir
				  :remove-repeated-chords t)
  (utils:message "Study 1 analyses complete!")))

;;;; Utility functions

(defparameter *harmony-viewpoints* '(h-bass-cpc
				     h-bass-cpcint
				     h-bass-csd
				     h-bass-int-from-gct-root
				     h-cpc-int-from-bass
				     h-cpc-int-from-gct-root
				     h-cpc-milne-sd-cont=min
				     h-cpc-vl-dist-p=1
				     h-cpitch
				     h-cpitch-class-set
				     h-csd
				     h-gct-3rd-type
				     h-gct-7th-type
				     h-gct-base
				     h-gct-ext
				     h-gct-meeus-int
				     h-gct-root-5ths-dist
				     h-gct-root-cpc
				     h-gct-root-cpcint
				     h-gct-root-csd
				     h-hash-12
				     h-hedges-chord-type
				     h-hutch-rough
				     (h-csd h-bass-csd)
				     (h-cpc-int-from-bass h-bass-cpcint)
				     (h-cpc-int-from-gct-root h-gct-root-cpcint)))

(defun analyse-all-viewpoints
    (dataset pretraining-ids
     &key reduce-harmony reduce-harmony-pretraining
       (output-path "/home/peter/idyom-output/study-1/")
       (k 10) training-set-size
       (remove-repeated-chords t))
  (let ((viewpoints *harmony-viewpoints*))
    (analyse-viewpoints viewpoints dataset pretraining-ids
			:reduce-harmony reduce-harmony
			:reduce-harmony-pretraining reduce-harmony-pretraining
			:output-path output-path :k k
			:training-set-size training-set-size
			:remove-repeated-chords remove-repeated-chords)))

(defun analyse-viewpoints
    (viewpoints dataset pretraining-ids
     &key reduce-harmony reduce-harmony-pretraining
       (output-path "/home/peter/idyom-output/study-1/")
       (k 10)
       training-set-size
       (remove-repeated-chords t))
  "Analyses a set of viewpoints on a given dataset."
  (assert (listp viewpoints))
  (let ((num-viewpoints (length viewpoints)))
    (utils:message (format nil "Analysing ~A viewpoints with dataset ~A."
			   num-viewpoints dataset))
    (loop
       for viewpoint in viewpoints
       for i from 1
       do (progn
	    (utils:message (format nil "Analysing viewpoint ~A/~A (~A)."
				   i num-viewpoints viewpoint))
	    (analyse-viewpoint viewpoint dataset pretraining-ids reduce-harmony
			       reduce-harmony-pretraining
			       :output-path output-path :k k
			       :training-set-size training-set-size
			       :remove-repeated-chords remove-repeated-chords)))))

(defun analyse-viewpoint
    (viewpoint dataset pretraining-ids reduce-harmony reduce-harmony-pretraining
     &key (output-path "/home/peter/idyom-output/study-1/")
       (k 10) training-set-size (remove-repeated-chords t))
  "Analyses a derived viewpoint, identified by symbol/list <viewpoint>,
on dataset with ID <dataset>, saving the output to a sub-directory
of <output-path>, which will be created if it doesn't exist.
This subdirectory will be identified by the dataset and the viewpoint.
If <reduce-harmony> is true, harmonic reduction is applied to 
the test dataset before analysis.
If <reduce-harmony-pretraining> is true, harmonic reduction is applied to 
the pretraining dataset before analysis.
The analysis uses <k> cross-validation folds.
<pretraining-ids> is a list of datasets to pretrain on.
If <trainining-set-size> is not null, it should be an integer corresponding
to the size that each training set should be downsized to."
  (assert (integerp dataset))
  (assert (listp pretraining-ids))
  (assert (or (listp viewpoint) (symbolp viewpoint)))
  (let* ((output-root-dir (utils:ensure-directory output-path))
	 (training-set-size-dir
	  (merge-pathnames
	   (make-pathname
	    :directory
	    (list :relative
		  "predictions"
		  (if pretraining-ids
		      (format nil "pretraining-~{~S-~}harmonic-reduction-~A"
			      pretraining-ids
			      (string-downcase (symbol-name
						reduce-harmony-pretraining)))
		      "pretraining-none")
		  (format nil "test-dataset-~A-harmonic-reduction-~A" dataset
			  (string-downcase (symbol-name reduce-harmony)))
		  (if training-set-size
		      (format nil "resampling-training-set-size-~A"
			      training-set-size)
		      "no-training-set-downsampling")))
	   output-root-dir))
	 (output-dir (merge-pathnames
		      (make-pathname :directory
				     (list :relative
					   (string-downcase
					    (if (listp viewpoint)
						(format nil "~{~A~^-x-~}"
							(mapcar #'symbol-name
								viewpoint))
						(symbol-name viewpoint)))))
		      training-set-size-dir)))
    (if (probe-file output-dir)
	(utils:message "Output directory already exists, skipping analysis.")
	(progn
	  (ensure-directories-exist output-dir)
	  (let* ((output-resampling-set-path
		  (namestring (merge-pathnames
			       (make-pathname :name "resampling" :type "lisp")
			       training-set-size-dir)))
		 (output-analysis-path
		  (merge-pathnames
		   (make-pathname :directory '(:relative "dat_from_idyom"))
		   output-dir))
		 (viewpoints::*basic-types* (list :h-cpitch)))
	    (idyom:idyom
	     dataset '(h-cpitch) (list viewpoint)
	     :k k :texture :harmony :models :ltm
	     :pretraining-ids pretraining-ids
	     :harmonic-reduction (if reduce-harmony
				     :regular-harmonic-rhythm
				     :none)
	     :pretraining-harmonic-reduction (if reduce-harmony-pretraining
						 :regular-harmonic-rhythm
						 :none)
	     :separator #\tab :detail 2.5
	     :use-resampling-set-cache? t
	     :slices-or-chords :chords
	     :remove-repeated-chords remove-repeated-chords
	     :resampling-set-cache-path output-resampling-set-path
	     :num-quantiles 12
	     :training-set-size training-set-size
	     :use-ltms-cache? nil
	     :overwrite nil
	     :output-path output-analysis-path))))))

(defun analyse-tps-all-viewpoints
    (dataset &key output-path reduce-harmony (remove-repeated-chords t)
	       n num-quantiles)
  (utils:message (format nil "Analysing transition probabilities (n = ~A) for ~A viewpoints in dataset ~A..."
			 n (length *harmony-viewpoints*) dataset))
  (let* ((data (md:get-music-objects (list dataset) nil
				     :voices nil :texture :harmony
				     :harmonic-reduction (if reduce-harmony
							     :regular-harmonic-rhythm
							     :none)
				     :slices-or-chords :chords
				     :remove-repeated-chords remove-repeated-chords))
	 (data (progn (utils:message "Adding local key cache.")
		      (mapcar #'viewpoints:add-local-key-cache data))))
    (loop for viewpoint in *harmony-viewpoints*
       do (analyse-tps-viewpoint viewpoint data dataset
				 :output-path output-path
				 :reduce-harmony reduce-harmony
				 :n n :num-quantiles num-quantiles))))

(defun analyse-tps-viewpoint
    (viewpoint data dataset &key output-path reduce-harmony
	       n num-quantiles)
  (let* ((output-root-dir output-path)
	 (output-leaf-dir (ensure-directories-exist
			   (merge-pathnames
			    (make-pathname
			     :directory
			     (list :relative
				   "transition-probabilities"
				   (format nil "~A-harmonic-reduction-~A" dataset
					   (string-downcase (symbol-name reduce-harmony)))
				   (format nil "n=~A" n)
				   (format nil "quantiles=~A" num-quantiles)))
			    output-root-dir)))
	 (output-path (merge-pathnames (concatenate 'string
						    (string-downcase
						     (if (listp viewpoint)
							 (format nil "~{~A~^-x-~}"
								 (mapcar #'symbol-name
									 viewpoint))
							 (symbol-name viewpoint)))
						    ".csv")
				       output-leaf-dir)))
    (if (probe-file output-path)
	(utils:message
	 (format nil
		 "TPs already exist (dataset = ~A, n = ~A, viewpoint = ~A, quantiles = ~A), skipping analysis."
		 dataset n viewpoint num-quantiles))
	(let* ((viewpoints:*discretise-viewpoints* nil))
	  (when (and num-quantiles
		     (viewpoints:continuous-p (viewpoints:get-viewpoint viewpoint)))
	    (viewpoints:set-viewpoint-quantiles viewpoint data num-quantiles)
	    (setf viewpoints:*discretise-viewpoints* t))
	  (utils:message (format nil "Computing transition probabilities (n = ~A) for dataset ~A, viewpoint ~A"
				 n dataset viewpoint))
	  (descriptives:write-csv (descriptives:get-viewpoint-transition-probabilities data n viewpoint)
				  output-path)))))

(defun save-viewpoint-quantiles
    (dataset &key output-path reduce-harmony num-quantiles (remove-repeated-chords t))
  (utils:message "Computing and saving viewpoint quantiles...")
  (let* ((output-root-dir (utils:ensure-directory output-path))
	 (output-leaf-dir (ensure-directories-exist
			   (merge-pathnames
			    (make-pathname
			     :directory
			     (list :relative
				   "viewpoint-quantisation-boundaries"
				   (format nil "~A-harmonic-reduction-~A" dataset
					   (string-downcase (symbol-name reduce-harmony)))
				   (format nil "quantiles=~A" num-quantiles)))
			    output-root-dir)))
	 (data (md:get-music-objects (list dataset) nil
				     :voices nil :texture :harmony
				     :harmonic-reduction (if reduce-harmony
							     :regular-harmonic-rhythm
							     :none)
				     :slices-or-chords :chords
				     :remove-repeated-chords remove-repeated-chords)))
    (loop for v in *harmony-viewpoints*
       when (viewpoints:continuous-p (viewpoints:get-viewpoint v))
       do (let ((viewpoints:*discretise-viewpoints* nil)
		(output-file (merge-pathnames
			      (concatenate 'string
					   (viewpoints:viewpoint-name-string v)
							   ".csv")
			      output-leaf-dir)))
	    (if (probe-file output-file)
		(utils:message "Output file exists aready, skipping analysis.")
		(viewpoints:set-viewpoint-quantiles v data num-quantiles
						    :output-path output-file))))))
	    
	 
  
					   
	 
	   