;;;; ======================================================================
;;;; File:       generics.lisp
;;;; Author:     Marcus Pearce <marcus.pearce@qmul.ac.uk>
;;;; Created:    <2004-10-28 11:56:59 marcusp>
;;;; Time-stamp: <2015-02-27 11:17:20 marcusp>
;;;; ======================================================================

(cl:in-package #:database)

(defgeneric export-data (object type path))
(defgeneric import-data (type path description id))
(defgeneric insert-composition (dataset composition id))
(defgeneric insert-event (composition event id))
(defgeneric get-attribute (event attribute))
(defgeneric set-attribute (event attribute value))
(defgeneric copy-event (object))

