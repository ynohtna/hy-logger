(setv *get-compile-time-filter-def*
      (fn []
        (import [os [getenv]])
        (getenv "HY_LOGGER_FILTER"
                "(accept >=debug)")))
