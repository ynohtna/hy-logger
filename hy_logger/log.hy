(eval-and-compile
  (import [.levels [*default-level*]]
          [.compile-time [*get-compile-time-filter-def*]]))

(defmacro -get-compile-time-filter-def []
  (*get-compile-time-filter-def*))

(eval-and-compile
  (import [.spec-def [parse-spec]]
          [.filter-def [->filter]])
  (setv *spec-cache* {}
        *compile-time-filter-def* (-get-compile-time-filter-def)
        *compile-time-filter* (->filter *compile-time-filter-def*)))


(defn parse-and-cache-spec [spec]
  (setv s (parse-spec spec *default-level*))
  (assoc *spec-cache* spec s)
  s)


(defn run-middlewares [data ms]
  (for [m ms]
    (setv data (m data))
    (unless data
      (return)))
  data)


(defmacro! log! [o!logger spec &rest args]
  (import [hy-logger.log [*spec-cache* parse-and-cache-spec]])
  (setv spec (if (in spec *spec-cache*)
                 (get *spec-cache* spec)
                 (parse-and-cache-spec spec))
        nss  (first spec)
        lvl  (second spec))
  ;; test nss & lvl against compile-time filter
  (when (and (len args)
             (not (*compile-time-filter* nss lvl)))
    ;; test logger, then nss & lvl against logger filters
    `(when (and ~g!logger
                (not (some (fn [filter] (filter ~nss ~lvl))
                           (:filters ~g!logger []))))
       ;; construct log event definition
       (setv data {
                   :args ~args
                   :nss  ~nss
                   :lvl  ~lvl
                   :cfg  ~g!logger
                  })
       ;; pass log data through middlewares...
       (when (or (not (:middlewares ~g!logger False))
                 (do
                   (import [hy-logger.log [run-middlewares]])
                   (setv data (run-middlewares data (:middlewares ~g!logger)))
                   data))
         ;; if it survives, feed to each appender.
         (for [[key appender] (.items (:appenders ~g!logger []))]
           (assoc data
                  :appender key)
           (appender data))))))
