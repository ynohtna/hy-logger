hy-logger
=========

A simple, lightweight, pluggable logging sub-system for Hy_ (a dialect of Lisp embedded in Python),
with a design strongly inspired by Peter Taoussanis' Timbre_ library for Clojure.

.. _Timbre: https://github.com/ptaoussanis/timbre
.. _Hy: https://github.com/hylang/hy


Features
--------

* Minimal API surface, designed for easy extensibility.
* Zero dependencies.
* Configured from a simple map: no external configuration file needed.
  Configs are easily passed around, exported, composed and programmatically mutated.
* Log events can be optionally tagged as belonging to multiple namespaces to enable custom filtering,
  processing, output routing, etc.
* Built-in filtering mini-DSL to clearly specify event accept/deny conditions against log levels.
* Compile-time filtering to exclude log statements from source for zero overhead production builds.
* Pluggable run-time filtering against log levels and event namespaces.
* Middleware model to augment log data with timestamps, thread/process info, manipulate arguments,
  decode stack traces, etc. Middleware can also further filter log events.
* Simple multiple output appender API, called with raw log event data.
  Supports structured value logging, async dispatch rate limiting, etc.


Basic Usage
-----------

.. code:: Lisp

  (import [hy-logger.appenders [->print-appender]])
  (require [hy-logger [log!]])

  ;; logger definition
  (setv logger {
                ; send log events to a single appender which simply prints all
                ; log event arguments to sys.stdout
                :appenders [(->print-appender)]
               })

  (log! logger :foo:bar:debug "Hello world." "Is this your password?" (+ 1000 230 4))
  ; => Hello world. Is this your password? 1234

  ;; "foo" and "bar" are the namespaces associated with the log event.
  ;; "debug" is it's log level.

  ;; define a helper macro to avoid having to repeatedly specify the logger.
  (defmacro log [&rest args]
    `(log! logger #* args))

  ;; Namespaces are optional per log event.
  ;; A single log level must always be specified, chosen from:
  ;;   [:trace  :debug  :info  :warn  :error  :fatal  :report]

  (log :info "hy-logger operational")
  ; => Hello, world.



Concepts
--------

Log Events
~~~~~~~~~~

Single log statement, intended for side-effects.

log! macro, logger, spec, arguments.


Logger
~~~~~~

Simple map defining (all optional): filters, middlewares, appenders.
Can be passed as an argument, composed, duplicated, manipulated.
No singleton definition affords different logging semantics for separate modules.
Users expected to write convenience macros to reduce boilerplate.

Example of an application global def...


Event Spec
~~~~~~~~~~

Namespaces, log levels. Staticly defined.
Default level.


Filtering
~~~~~~~~~

Compile-time filtering.
Run-time filtering, filtering mini-DSL.


Middleware
~~~~~~~~~~

Augmenting, manipulating, formatting, filtering, hy-repr.
Time stamps, stack trace, style map, highlighting.


Appenders
~~~~~~~~~

Built-ins: print, collect, spit.
Async, rate limiting, splitting off high-level events and specific namespaces, colouring.



More Usage Examples
-------------------


To Do
-----

- Code tests and error handling for malformed log expression where namespace spec is non-static.
- Modifiable compile-time determination mechanism? **In-progress**
- Determine real use case for dynamic namespacing of events (are there any?) and
  relax the constraint that log event specs must be specified staticly.
- Util macro to generate convenience functions for a namespace over the different log levels.


.. code:: Lisp

   ;; ping.hy
   (require [hy-logger [gen-log-macros]])

   (setv ping-logger { ; ...custom logger definition
                     })

   (gen-log-macros :ping ping-logger plog-)

   ;; macros now available named plog-t, plog-d, plog-i, plog-w, plog-e, plog-f, plog-r,
   ;; as well as the longer forms: plog-trace, plog-debug, plog-info, etc...
   ;; i.e.: (defmacro plog-debug [&rest args]
   ;;          `(log! :ping:debug ping-logger #* args))

   (defn do-ping []
     ;...
     (plog-info "done a ping!"))

