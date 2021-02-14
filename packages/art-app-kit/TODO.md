

# New Features

### Routes

We need this anyway, but how to do it nicely?

```
# And, when we know our routes, pageStack can have:
models.pageStack.route {} review

# instead of this:
models.pageStack.push :review {} @review
```

### PageStack

- export pageStack so we can access it directly without models.pageStack (this flys in the face of our ReactJS + Models plans, though, but hey, that doesn't matter here since this is ArtEngine only anyway)
- provide action wrappers which pushes an error-message-page if myPromise fails
  - `pageStack.managedAction myPromise`
  - `pageStack.managedAction {popAfter: true}, myPromise`
