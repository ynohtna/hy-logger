(import [re [compile :as re/compile]]
        [hy [HySymbol]]
        [.levels [str->lvl *level-name-regex*]])
(require [hy.extra.anaphoric [%]])


;; Log namespace def is a sequence of identifier chars, optionally followed by a wildcard asterisk.
(setv ns-def-regex (re/compile "([a-z-_]+)(\*)?"))

;; Log level def is an optional comparison operator followed by a lowercase log level identifier.
(setv lvl-def-regex (re/compile (+ "(>|>=|<|<=)?" *level-name-regex*.pattern)))


(defn parse-lvl-def [def]
  (when (= def "*")
    (return "*"))
  (setv match (.fullmatch lvl-def-regex def))
  (cond [(none? match)
         None]
        [(match.group 1)
         `(~(HySymbol (match.group 1)) lvl ~(str->lvl (match.group 2)))]
        [True
         `(= lvl ~(str->lvl (match.group 2)))]))


(defn parse-ns-def [def]
  (setv match (.fullmatch ns-def-regex def))
  (if match
      (if (match.group 2)
          `(.startswith ns ~(match.group 1))
          `(= ns ~def))
      (raise (SyntaxError f"invalid ns def {def}"))))


(defn match-any-of [&rest options]
  (setv opts (list #* options)
        l (len opts))
  (cond [(= 0 l)
         `True]
        [(= 1 l)
         (first opts)]
        [True
         `(or ~@opts)]))

(defn parse-ns-lvl-defs [defs]
  (as-> (last defs) maybe-lvl
        (parse-lvl-def maybe-lvl)
        (cond [(= "*" maybe-lvl)
               (match-any-of (map parse-ns-def (butlast defs)))]
              [(and maybe-lvl (= 1 (len defs)))
               maybe-lvl]
              [maybe-lvl
               `(and ~(match-any-of (map parse-ns-def (butlast defs)))
                     ~maybe-lvl)]
              [True
               (match-any-of (map parse-ns-def defs))])))


(defn parse-filter-def [def]
  (import [hy.lex [tokenize]]
          [funcparserlib.parser [a many maybe oneplus]]
          [hy.model-patterns [pexpr sym SYM whole]])
  (setv ns-lvl-def (>> SYM (fn [ns-lvl]
                             (setv conds (parse-ns-lvl-defs
                                           (->> (.split ns-lvl ":")
                                                (filter identity)
                                                list)))
                             conds))
        accept-def (>> (pexpr (sym "accept")
                              (oneplus ns-lvl-def))
                       #% `(not ~(match-any-of %1)))
        deny-def   (>> (pexpr (sym "deny")
                              (oneplus ns-lvl-def))
                       #% (match-any-of %1))
        some-defs  (>> (many (| accept-def deny-def))
                       #% (cond [(empty? %1)
                                 `None]
                                [True
                                 `(cond ~@(list (map (fn [c] [c]) %1)))]))
        parser     (>> (whole [some-defs])
                       (fn [some-defs]
                         `(fn [ns lvl]
                            ~(first some-defs)))))
  (->> (tokenize def)
       (.parse parser)))


(defn ->filter [def]
  (setv f (parse-filter-def def))
  (eval f))
