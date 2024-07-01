# TODO

- Eventually we will want a way to say that some record updates should not be returned client-side.
  - First pass
    - data has already gone through the after-pipeline, so any after-filters can removed fields
      the current user can't see. TODO: create privacy filters
- Do we properly handle updates where a field of a record was set to NULL?
  - If we strip NULLs in return objects, then the client-side update, if it's a merge and not a replace wouldn't get the NULL-out signal.
