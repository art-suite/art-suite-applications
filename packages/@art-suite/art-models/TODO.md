
# Feature Ideas

### Yet Another Cool Subscriptions Convention

This:
```
class Organization extends FluxComponent

  @subscriptions
    :organization
    userOrganizationsByOrganizationId: ({organizationId}) -> organizationId
```

Could be this:
```
class Organization extends FluxComponent

  @subscriptions
    :organization
    :userOrganizationsByOrganizationId
```

If the string contains exactly `/[a-z]By([A-Z][a-zA-Z])$/` we can assume the key is defined by the matched $1 in props.

### ArtModelStoreEntry and ArtModelRecords / ArtModelStoreEntryRecords

We just have too many data-types! We should do something about this. Opions:

- We should define the "modelRecords" structure concretely. (ArtModelRecord)
- It would be nice if we could merge modelRecords in to Entries... They are 1:1, however we want to treat modelRecords as immutable by Entries ARE mutable.