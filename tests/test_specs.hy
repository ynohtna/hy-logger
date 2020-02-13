(import [hy-logger.levels [*log-levels* *default-level*]]
        [hy.contrib.hy-repr [hy-repr]])
(require [hy-logger.spec-def [parse-spec*]])


(setv dbg   (:debug *log-levels*)
      warn  (:warn *log-levels*)
      error (:error *log-levels*))


(eval-when-compile
  (import [hy.contrib.hy-repr [hy-repr]]))

(defmacro assert-spec [spec nss lvl]
  `(do
     (setv p   (parse-spec* ~spec *default-level*)
           ns  (first p)
           lvl (second p))
     (print ~(str spec) (hy-repr p))
     (assert (= ns ~nss) "assert-spec ns mismatch")
     (assert (= lvl ~lvl) "assert-spec lvl mismatch")
     (print "OK\n")))


(defmacro assert-specs [&rest forms]
  `(do
     ~@(map (fn [form]
              `(assert-spec ~@form))
            forms)))


(assert-specs [:pingu
               ["pingu"] dbg]

              [:pingu:warn
               ["pingu"] warn]

              [:pinger:autobot::error:
               ["pinger" "autobot"] error]

              [:pingu:fatally:warn
               ["pingu" "fatally"] warn]

              [:pingu:fatal:debug
               ["pingu" "fatal"] dbg])

(setv *default-level* 999)
(assert-specs [:smurf:osc-in:osc
               ["smurf" "osc-in" "osc"] 999])

(setv *default-level* dbg)
(assert-specs [:smurf
               ["smurf"] dbg]
              [:debug
               [] dbg]
              [:::::debug::::
               [] dbg])
