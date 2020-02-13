(import sys)
(setv *expected-compile-time-def* (second sys.argv))

(require [hy-logger.log [log!]])
(import [hy-logger.log [*compile-time-filter-def*]])


(print (* "-" 60))
(print "= COMPILE TIME FILTERING\n")

(assert (= *compile-time-filter-def*
           *expected-compile-time-def*)
        (+ "expected compile-time filter to be " *expected-compile-time-def*
           " but it's " *compile-time-filter-def*))
(print "OK" "compile-time filter is" *expected-compile-time-def* "as expected")


(setv collected []
      logger {
              :appenders {
                          :coll (fn [data]
                                  (.append collected (.join " " (:args data)))
                                  (print (:lvl data) (:nss data)
                                         #* (:args data)))
                         }
             })
(defmacro log [&rest args]
  `(log! logger ~@args))

(defmacro assert-collected [log-form expected]
  `(do
     (.clear collected)
     ~log-form
     (assert (= 1 (len collected)) (+ "collected nothing when expecting: " ~expected))
     (assert (= (first collected) ~expected)
             (+ "unexpected output: " (first collected) " != " ~expected))))

(defmacro assert-filtered [log-form]
  `(do
     (.clear collected)
     ~log-form
     (assert (empty? collected) (+ "collected unexpectedly non-empty: " (repr collected)))))


(print (+ "\n" (* "-" 60) "\n"))

(assert-filtered
  (log :test:debug "~dbg~"))

(assert-filtered
  (log :test:info "info-bot"))

(assert-filtered
  (log :test:trace "trace-elided"))

(assert-collected
  (log :test:error "error msg")
  "error msg")

(assert-collected
  (log :test:fatal "fatal repulsion")
  "fatal repulsion")

(assert-collected
  (log :retort:report "news report" (str (+ 2 (* 3 4))))
  "news report 14")

(print "OK\n")
