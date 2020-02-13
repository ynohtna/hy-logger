(import [functools [partial]])


(defn ->collector [appendable]
  (partial (fn [arr data]
             (.append arr data))
           appendable))


(defn ->print-appender [&rest prefixes]
  (partial (fn [pre data]
             (print #* pre
                    #* (or (:formatted data None)
                           (:args data))))
           prefixes))


(defn ->spit-appender [filename]
  (partial (fn [fname data]
             (with [fh (open fname "a")]
               (.write fh (or (:formatted data None)
                              (.join " " (:args data))))
               (.write fh "\n")))
           filename))
