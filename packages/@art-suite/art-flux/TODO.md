
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