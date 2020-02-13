(require [hy-logger.log [log!]])
(import [hy-logger [->filter]])

(setv collected []
      collector {
                 ;; [(fn [nss lvl] -> ?True)]
                 :filters     [(->filter "(deny <warn)")]

                 ;; Middleware is applied left to right, transforming/augmenting
                 ;; data as it goes. Any middleware returning None cancels the event.
                 ;;   [(fn [data]) -> ?data]
                 :middlewares []

                 ;; Appenders are a dict with a single mandatory key :fn
                 ;;   {key: (fn [data]) -> side effects}

                 ;; The data map has these keys (plus additions/changes by middleware):
                 ;;   :args  [list of raw log call args]
                 ;;   :lvl   [log event level (int)]
                 ;;   :nss   [list of log event's namespaces]
                 ;;   :cfg   entire logger config map (filters, middlewares, etc)
                 ;;   :appender      key of appender currently dispatching
                 :appenders {
                             :println (fn [data]
                                        (print #* (:args data))
                                        #_(print data "\n")
                                        (.append collected (:args data)))
                            }
                }
      hail-satan 666
      nice 69)


(log! collector :test-ns1:debug "a debug msg" 123 4.56)
(log! collector :test-ns2:trace "a trace msg" 0 0 0)
(log! collector :stats:pokemon:report "super effective hail satan" hail-satan nice (* 3 23))
(log! collector :space:warn "but still they come..." (- nice))

(log! None :never:gonna:get:it "INVISBLE")
(log! collector :not:collected:no:args)

(defn log-h [&rest args]
  (log! collector :helper:report #* args))

(log-h "does fn wrapping" "work?")

;; FIXME: enable runtime specification of namespace/level parameters?
;;     NO. DENIED.
;; Macros can't determine that nss arg is a bound identifier at compile time.
;; Instead, appenders can interrogate first arg, initial char or whatever from args.
;; Namespacing and log level must be static, as they represent the code they
;; reside within and the event they're associated with.
;; Dynamic modulation is enabled via the runtime filters, middlewares and appenders.

(setv runtime-ns (* 111 6))
(log! collector :runtime:report runtime-ns "runtime namespacing through initial parameter convention")
(log! collector :runtime:info (, :indicator) "tuples can be readily distinguised")

(print "\n" collected)
(print "OK\n")

;; USE CASES:

;; exclude unneeded logging to improve a sub-system's performance
;; log sub-system info, but not WAMP super-system, or vice versa.
;; WAMP errors additionally logged to file for post-analysis/stats
;; exceptions reported especially via notifications/off-site
;; statistic reports collected remotely
;; autobot per-component inspection:
;;   warn/error/fatal/report for pinger
