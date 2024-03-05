# LinkFieldsFilters

# Use

# TODO:

This should work:
```coffee
class Foo extends Pipeline
  @fields
    matchingUserFriendInvite:     "link"
    # should be the same as:
    # matchingUserFriendInvite:     link: :userFriendInvite
```

In other words, the "link" keyword should auto detect matching pipeline
names as suffixes, in descending length order, in addition to matching the full name.

You can still specify it explicitly as shown in the comment.