(import hy-logger)

(deftag run-test: [module-name]
  `(do
     (print)
     (print (* "=" 60))
     (print "=" (.upper ~(str module-name)) "\n")
     (import ~module-name)))

#run-test: test-filters
#run-test: test-specs
#run-test: test-logger
#run-test: test-appenders
#run-test: test-middleware
