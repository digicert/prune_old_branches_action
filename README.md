# Delete Old Branches

This action deletes branches that haven't had a commit in the last X days, and deletes the oldest tags.

DO NOT USE v3 as it has a bug

## Requirements

Requires the repo to be checked out, this can be done with the actions/checkout@v2 action on the marketplace

## Inputs

### `numDays`

The number of days after which the branches will be deleted.

Required | Default
-------- | -------
False | 180

### `numTags`

The number of most recent tags. (Set to 0 to delete all tags)

Required | Default
-------- | -------
False | 5

## Example Usage
```yaml
steps:
  # To use this action, you must check out the repository
  - name: Checkout
    uses: actions/checkout@v2
    with:
      fetch-depth: 0
  - name: Cleanup
    uses: digicert/prune_old_branches_action@v1
    with:
      numDays: '200'
      numTags: '3'
```
