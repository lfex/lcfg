(defmodule lcfg
  (export all))

(defun start ()
  'ok)

(defun start (_type _args)
  `#(ok ,(self)))

(defun clone-deps ()
  (lcfg-deps:clone-deps))

(defun get-in (args)
  (clj:get-in (lcfg-file:parse) args))

(defun get-in
  ((_ 'undefined)
   '())
  ((config '())
   config)
  (('local args)
    (lutil-type:get-in (lcfg-file:read-local) args))
  (('global args)
    (lutil-type:get-in (lcfg-file:read-global) args))
  ((config args)
    (lists:foldl #'get/2 config args)))

(defun get-in (config default args)
  (let ((result (get-in config args)))
    (case result
      ('false default)
      ('undefined default)
      ('() default)
      (_ result))))

(defun get (key config)
  ;; Note that when a keyfind returns false, we need to return an empty list
  ;; so that get-in's foldl will work at any depth.
  (case (lists:keyfind key 1 config)
    ('false '())
    (result (element 2 result))))

(defun get (key default config)
  (let ((result (get key config)))
    (case result
      ('false default)
      ('undefined default)
      ('() default)
      (_ result))))

(defun update (key value)
  (update key value (lcfg-file:read-local)))

(defun update (key value config)
  (lists:keyreplace key 1 config `#(,key ,value)))
