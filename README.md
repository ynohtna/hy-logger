# Hy Logger

* Log statements can be excised completely from the source code at compiled time.
* Runtime log statement filtering against namespaces and log levels.
* Extensible via middleware to augment logging data with timestamps, thread id, etc.
* Pluggable output appenders to adapt to varying log destinations.

```hy
(import [logger [->logger]]
        [logger.appenders [print-appender]])
(require [logger [log!]])

(setv logger (->logger
                :filters ["(accept main:* >=debug)"]
                :appenders [print-appender]))

(log! logger :main:trace "Trace message")
(log! logger :warn "Something is afoot!")

(defmacro log [&rest args]
  "helper macro for concise local usage"
  `(log! logger ~@args))

(log :stats:report {:count 69  :nice True  :max "headroom"})
```
