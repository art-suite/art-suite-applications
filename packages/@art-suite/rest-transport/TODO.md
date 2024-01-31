# TODO

- Constructor

  - We need to generalize Access control.

    - We need a way to say GET is only allowed by Owner or people who are allowed via requireUserCanUpdate
      - new option idea: requireUserAuthorized request, existingRecord
        - NOTE: I think this should be ANDed with userUpdatableFields / userCreatableFields - both tests must pass
        - NOTE: userUpdatableFields / userCreatableFields should ignore if you are the owner, they apply consistently for all non-server-origin reqeusts
          (I think this is how they work already)
    - might want a the option for a custom function to generate allowedFields (filtering response records)
      - new option idea: filterResponseRecord request, record -> filtered record or null to skip record
    - publicFields needs to have expandPossiblyLinkedFields applied!
      hmm. it IS applied. This field-def doesn't get expanded

      fields:
      parentGoal: link: :goal

-REST

- Change PUT to PATCH; that's really what we are doing.

  - https://medium.com/@kamaleshs48/difference-between-put-post-and-patch-35ed362e05e9
  - we could add optional support for "replace" which would route to PUT in REST.

- OpenAPI

  - Make queries work for OpenAPI - e.g. they should return (data: array: :record), but it doesn't work
  - CRUD UPDATE need to let all fields be optional, even if they are otherwise required.
    - Currently the OpenAPI implementation uses the same, shared schema as CREATE
