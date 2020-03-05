(import [datetime [datetime]]
        [functools [partial]])


(defn ->time-stamper [&optional [formatter str]]
  "Adds :timestamp and :when-text keys to log data."
  (partial (fn [formatter data]
             (setv now (.now datetime))
             (assoc data
                    :timestamp  now
                    :when-text  (formatter now))
             data)
           formatter))
