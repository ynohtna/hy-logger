(import [.levels [*level-name-regex* str->lvl]])


;; split spec by colons
;; test last def against known levels
;; split into tuple (resp. default) accordingly
(defn parse-spec [spec default]
  (setv nss (-> spec
                name
                (.split ":")
                (->> (filter identity))
                list)
        maybe-lvl (first (cut nss -1))
        lvl?    (.fullmatch *level-name-regex* (or maybe-lvl ""))
        lvl     (if lvl?
                    (str->lvl maybe-lvl)
                    default))
  (if lvl?
      (, (cut nss 0 -1) lvl)
      (, nss lvl)))


(defmacro parse-spec* [spec default]
  `(do
     (import [hy-logger.spec-def [parse-spec :as spec/parse]])
     (spec/parse ~(name spec) ~default)))
