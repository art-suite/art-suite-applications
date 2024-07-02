# TODO

### Filters Groups

Trying to figure out what to do better with filter grouping.

Really, I think there are 3 main groupings of filters for order:

1. validation: first and last of all filters
  - before-filters validate the pre-transformed input data
  - after-filters enforce the client only sees what they are allowed to see
2. transformation:
  - before-filters pre-process the data and get it into the final form for the DB
    - e.g. timestamps & UUIds for create
  - after-filters post-process the data and get it into the final form for the client
3. actions:
  - before-filters: after the data has been validated and transformed, side-actions can happen; update other records, etc...
  - after-fitlers: after the Db is done, these can use the raw results to trigger other side actions.

For each of those 3 groups, a filter might want to be on the "inner" side of the filter chain, or the "outer" side.

- inner: as a before-filter, inner will run AFTER all other filters defined so far for that level. As an after-filter, it'll run BEFORE.
- outer: as a before-filter, it'll run BEFORE all others at the same level, and as an after-fitler, AFTER all others.

Outer is usually the default

```coffee
class MyPipe extends Pipeline
  @filter
    order: "inner validation"
    before: create: (request) ->
```

Previously I'd also identified: logging and authorization as order-groups:
```
  loggers beforeFilter
    authorization beforeFilter
      outer beforeFilter
        middle beforeFilter
          inner beforeFilter
            handler
          inner afterFilter
        middle afterFilter
      outer afterFilter
    authorization afterFilter
  loggers afterFilter
```
