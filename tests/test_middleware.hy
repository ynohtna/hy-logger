(import [hy-logger.appenders [->collector]])
(require [hy-logger [log!]])


(defn add-smurf [data]
  (assoc data :args ["PAPA" #* (:args data)])
  data)

(defn output-str [data]
  (assoc data :output-str (.join " " (:args data)))
  data)


(setv collection []
      m-logger {
                :middlewares [add-smurf output-str]
                :appenders {
                            :coll (->collector collection)
                           }
               })

(log! m-logger :mw:report "do" "re" "mi")
(assert (= 1 (len collection)))
(assert (= "PAPA" (-> collection first :args first)))
(assert (= "PAPA do re mi" (-> collection first :output-str)))
(print "OK  middleware augmentation\n")


(setv rip-collection []
      rip-logger {
                  :middlewares [(constantly None)]
                  :appenders {
                              :coll (->collector rip-collection)
                             }
                 })

(log! rip-logger :mw:rip:report "evaporate this" "msg")
(assert (empty? rip-collection) "rip-logger middleware should block log events")
(print "OK  rip-middleware\n")
