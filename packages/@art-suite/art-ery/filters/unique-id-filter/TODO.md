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
