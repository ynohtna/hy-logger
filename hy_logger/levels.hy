(import [re [compile :as re/compile]])


(setv *log-levels* {
                    :trace    5
                    :debug   10
                    :info    20
                    :warn    30
                    :error   40
                    :fatal   50
                    :report  60
                   })

(setv *default-level* (:debug *log-levels*))

(setv *log-levels-names* (set (map name *log-levels*)))

(setv *level-name-regex* (re/compile (+ "("
                                        #* (interpose "|" *log-levels-names*)
                                        ")")))


(defn str->lvl [s &optional default]
  (as-> (keyword s) kw
        (if (in kw *log-levels*)
            (get *log-levels* kw)
            default)))


(defn kw->lvl [kw &optional default]
  (if (in kw *log-levels*)
      (get *log-levels* kw)
      default))
