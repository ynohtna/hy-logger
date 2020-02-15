Hy Logger
=========

A simple, lightweight, pluggable logging sub-system for Hy, strongly inspired by
Peter Taoussanis' Timbre_ library for Clojure.

.. _Timbre: https://github.com/ptaoussanis/timbre


Features
--------

* Minimal API surface, designed for easy extensibility.
* Configured from a simple map or maps: no external configuration file needed.
  Configs are easily passed around, exported, composed and programmatically mutated.
* Log events can be tagged as belonging to multiple namespaces.
* Compile-time filtering to exclude log statements from source for zero overhead production builds.
* Pluggable run-time filtering against log levels and event namespaces.
* Built-in filtering mini-DSL to clearly specify accept/deny conditions.
  Custom run-time filters are easily used instead.
* Middleware model to augment log data with timestamps, thread/process info, manipulate arguments,
  decode stack traces, etc. Middleware can also further filter log events.
* Simple multiple output appender API, called with raw log event data.
  Supports structured value logging instead of strings, async dispatch rate limiting, etc.


Basic Usage
-----------

.. code:: Lisp

  (import [hy-logger.appenders [->print-appender]])
  (require [hy-logger [log!]])

  (setv logger {
                :appenders [(->print-appender)]
               })

  (log! logger :foo:bar:debug "hello world")

  (defmacro log [&rest args]
    `(log! logger #* args))

  (log :debug "I said howdy, weird.")



Concepts
--------

Log Events
~~~~~~~~~~

Single log statement, intended for side-effects.

log! macro, logger, spec.


Logger
~~~~~~

Simple map defining (all optional): filters, middlewares, appenders.
Can be passed as an argument, composed, manipulated.
Different definition for separate modules.

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

Augmenting, manipulating, formatting, filtering.
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
- Modifiable compile-time determination mechanism?
- Determine real use case for dynamic namespacing of events (are there any?) and
  relax the constraint that log event specs must be specified staticly.
