(setv *get-compile-time-filter-def*
      (fn []
        (import os)
        (os.getenv "HY_LOGGER_FILTER"
                   "")))
