(import io
        os
        sys
        tempfile
        [hy.contrib.hy-repr [hy-repr]]
        [hy-logger.appenders [->print-appender ->collector ->spit-appender]])
(require [hy-logger [log!]])

(setv p-logger {
                :appenders  {
                             :prn (->print-appender "OK")
                            }
               })


(defn assert-captured [form expected]
  (with [s (io.StringIO)]
    (setv [prior sys.stdout] [sys.stdout s])
    (eval form)
    (setv sys.stdout prior
          result (.getvalue s))
    (print (hy-repr result))
    (assert (= expected result) expected)
    (print "OKAY  " (hy-repr expected) "\n")))

(assert-captured '(log! p-logger :appender:report "hi")
                 "OK hi\n")

(assert-captured '(log! p-logger :appender:report "a\nb")
                 "OK a\nb\n")

(assert-captured '(do
                    (log! p-logger :appender:report "watch this!")
                    (log! p-logger :appender:fatal "*RIP*"))
                 "OK watch this!\nOK *RIP*\n")

;; ----------------------------------------
(setv collected []
      c-logger {
                :appenders {
                            :coll (->collector collected)
                            }
                })

(log! c-logger :collector:report "do")
(assert (= 1 (len collected)))

(log! c-logger :collector:report "re")
(log! c-logger :collector:report "mi")
(assert (= 3 (len collected)))


;; ----------------------------------------
(log! p-logger :collector:report "->collector\n")

(setv [fh f-path] (tempfile.mkstemp)
      f-logger {
                :appenders {
                            :file  (->spit-appender f-path)
                           }
               })

(log! f-logger :file:report "HELLO FILE SYSTEM")
(with [fh (open f-path)]
  (assert (= (.read fh)
             "HELLO FILE SYSTEM\n") "file content mismatch")
  (print "OK ->spit-appender\n"))
(os.remove f-path)
