# Major Changes

### Returning null/undefined in a filter should return the passed-in request/response object instead of creating a "missing" response
  - handlers would still create a missing response for null/undefined
  - Con: filters and handlers have one more difference, but they are already different in other ways
  - Pro: often a filter decides it doesn't need to filter and/or it only has a side-effect, or it's only job is to throw an error on a condition - in all those cases, the success path means passing the request/response directly through. I have yet to EVER need a filter which returns a "missing" response.
  - Logic: "Handlers and Filters all have a reasonable default return value" - the handler can't just return the request - it has to generate SOME response... so missing makes sense. It's also a super helpful default value ;)
  - Transition: have a deprecation warning on all NULL/UNDEFINED from filters. Then

### Rework how "Both" mode works

Requests in "both" mode should look as much as the normal "client/server" mode as possible. As such, I am thinking about these changes:

- we run the client-side before-filter set, then we "restart" the request in "server" mode and run through all the server-filter-set, executing any "both" filters a second time.
- then we do the handler
- then we do the same pattern in reverse for after-filters
- EXCEPT - if we do a sub-request when we are already in "server" mode, that request should only do the server-filters, in "server" mode

That all sounds kinda complex, but I think if we find the right refactor it'll actually clean things up and simplify. Essentially we just eliminate the whole concept of "client/both/server" "modes" - instead, each request is either a "client" or "server" request, AND, we have the option of having the client-to-server router either be HTTPS -OR- a local route to a "local server" (or any other router in the future).

Hrm - one gotcha though is currently the client-side and server-side request handling each have their own filterLogs. This is correct, but for dev and test, we may want to be able to see everything that happened both client-side and server-side for one request. How to do that elegantly?!?!
  - to be clear, this isn't hard, it just needs some thought

Further thought 8/28/2021:

- Primary Goal: in "both" mode, we want to simulate client/server as accurately as possible
- Supporting Goals
  - Run ALL client filters
  - Then actually JSON encode and decode the request props (via the new 'transport' layer/filter feature)
  - Then run ALL the server filters
- Solutioning
  - I think we need the ability, per request, to say if it is a "client" request or a "server" request. I think we can then eliminate the entire global concept of client/server/both.
  - Then the only thing special about "both" mode is that the remoteServer is set null and therefor the HttpRestFilter will do the encode/decode and then re-issue the call with a "server" request.
### Transport Filter (is it a filter? or something new?)

Right now we have hard-coded a REST-api system for client<->server request transport. Really, this should just be another pluggable part of the stack.

Client: I'm inclined to say it's a Filter on the client-side. I think that would fully work.

Server: Server-side, we need an HTTP server (or anything else custom) to wrap around the ArtEry pipelines. All that needs to happen there is to invoke the requests server-side in "server" mode so that the client filters are skipped.