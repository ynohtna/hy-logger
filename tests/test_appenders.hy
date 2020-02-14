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

(assert-captured '(log! p-logger :appender:non-strings:report 1 2 {:a 1  :b 2} (* 2 3 4))
                 "OK 1 2 {HyKeyword('a'): 1, HyKeyword('b'): 2} 24\n")

(print "OK ->print-appender")


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

(print "OK ->collector\n")


;; ----------------------------------------

(setv [fh f-path] (tempfile.mkstemp)
      f-logger {
                :appenders {
                            :file  (->spit-appender f-path)
                           }
               })

(log! f-logger :file:report "HELLO FILE SYSTEM")
(log! f-logger :file:report "OK.")
(with [fh (open f-path)]
  (setv txt (.read fh))
  (print f-path "\n" (repr txt))
  (assert (= txt "HELLO FILE SYSTEM\nOK.\n")
          (+ "file content mismatch: " (repr txt)))
  (print "OK ->spit-appender\n"))
(os.remove f-path)
