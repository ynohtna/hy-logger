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


(defn ->lvl-styler [style-pairs &kwonly [key :style]]
  "Adds :style value to log data according to level scan in style-pairs."
  (partial (fn [style-pairs data]
             (setv l (:lvl data)
                   p (list (drop-while
                             (fn [def]
                               (< (first def) l))
                             style-pairs)))
             (assoc data key (if p
                                 (-> p first second)
                                 None))
             data)
           style-pairs))
