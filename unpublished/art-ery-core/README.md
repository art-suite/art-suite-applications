# Art.Ery.Core

A ground-up rewrite of Art.Ery's core Pipeline, Filters and Requests.

Goals:

- remove all client/server aspects from the "core"
- reduce complexity wherever possible
- mostly backward compatible except:
  - CHANGE: returning `undefined` from a filter is now the same as just returning the request untouched
  - CHANGE: there is no Response object anymore; it's all just a Request object

# TODO

- restore rejectIf\* capabilities
- restore sub-request capabilities
- make sure originalRequest works
- work on originatedOnServer (possible rename?)
- restore all getDetailedRequestTracingEnabled capabilities
