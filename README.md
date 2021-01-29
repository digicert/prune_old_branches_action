# Delete Old Branches

This action deletes branches that haven't had a commit in the last X days.

## Requirements

Requires the repo to be checked out, this can be done with the actions/checkout@v2 action on the marketplace

## Inputs

### `numDays`

The number of days after which the branches will be deleted.

Required | Default
-------- | -------
False | 180

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
```
