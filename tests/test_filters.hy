(import [hy-logger [parse-filter-def]]
        [hy.contrib.hy-repr [hy-repr]])


(defn compile-filter [def]
  (setv f (parse-filter-def def))
  (print f"\"{def}\"\n"
         (hy-repr f))
  (eval f))


(defmacro assertprn [form &optional [msg "assertp fail"]]
  `(try (assert ~form ~msg)
        (except [e Exception]
          (raise e))
        (else
          (import hy.contrib.hy-repr)
          (print "OK  " __name__ "  "
                 (hy.contrib.hy-repr.hy-repr '~form)))))

(defn assert-pass [&rest forms]
  (for [[f ns lvl] forms]
    (assertprn (not (= (f ns lvl) True))))
  (print))

(defn assert-fail [&rest forms]
  (for [[f ns lvl] forms]
    (assertprn (= (f ns lvl) True)))
  (print))


(setv f (compile-filter "(accept >=info ping*:error*:* tweaker:>=debug)(deny osc-in:<=warn osc-out:<=info)"))
(assert-pass [f "" 30]
             [f "pinger" 0]
             [f "error-checker" 5]
             [f "tweaker" 10]
             [f "osc-in" 40]
             [f "osc-out" 30])
(assert-fail [f "" 10]
             [f "ponger" 0]
             [f "errror" 5]
             [f "tweaker" 0]
             [f "osc-in" 10]
             [f "osc-out" 0])

(setv f (compile-filter "(accept twonk:>=fatal)\n(deny foo:bar)"))
(assert-pass [f "twonk" 50])
(assert-fail [f "twonk" 20]
             [f "foo" 100]
             [f "bar" 100])

(setv f (compile-filter ""))
(assert-pass [f "wtf" 0]
             [f "" -666])

(setv f (compile-filter "(accept *)"))
(assert-pass [f "wtf" 0]
               [f "" -666])

(setv f (compile-filter "(deny *)"))
(assert-fail [f "wtf" 0]
             [f "" -666])


(try
  (setv infoid "(accept >=infoid)(deny debugger)")
  (print f"\"{infoid}\"")
  (setv f (compile-filter infoid))
  (except [[SyntaxError]]
    (print "OK  >=infoid throws syntax exception.\n"))
  (else
    (raise (RuntimeError "expected invalid level spec syntax to throw "))))

(setv f (compile-filter "(accept >=info)(deny debugger)"))
(assert-pass [f "whatever" 20]
             [f "" 30])
(assert-fail [f "yeah" 10]
             [f "debugger" 911])

(setv f (compile-filter "(deny osc*)"))
(assert-pass [f "whatever" 0]
             [f "oosc" 33.3]
             [f "" 0])
(assert-fail [f "osc-in" 420]
             [f "osc-out-nice" -69])
