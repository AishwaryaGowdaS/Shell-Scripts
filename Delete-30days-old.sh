name: Delete Old Branches

on:
  workflow_dispatch:
    inputs:
      trigger:
        description: 'Trigger the workflow'
        required: true
        default: 'false'

jobs:
  delete_old_branches:
    runs-on: ubuntu-latest
    if: ${{ github.event.inputs.trigger == 'true' }}

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Fetch all branches
      run: git fetch --prune --tags

    - name: Calculate thirty days ago date
      id: calculate_date
      run: |
        current_date=$(date -u "+%Y-%m-%d")
        thirty_days_ago_date=$(date -d "-30 days" "+%Y-%m-%d" 2>/dev/null || date -j -v -30d "+%Y-%m-%d" 2>/dev/null)
    - name: List branches for debugging
      run: |
        git branch -r
        echo "$thirty_days_ago_date"
    - name: List branches with last commit date and delete if older than thirty days
      run: |
        current_date=$(date -u "+%Y-%m-%d")
        thirty_days_ago_date=$(date -d "-30 days" "+%Y-%m-%d" 2>/dev/null || date -j -v -30d "+%Y-%m-%d" 2>/dev/null)
        branches_to_delete=()
        for branch in $(git branch -r | grep -v HEAD | grep -v origin/release/*.* | grep -v origin/master | grep -v origin/staging | sed /\*/d); do
          last_commit_date=$(git log -1 --format="%ct" $branch)
          thirty_days_ago_timestamp=$(date -d "$thirty_days_ago_date" +%s)
          if [ "$last_commit_date" -lt "$thirty_days_ago_timestamp" ]; then
            echo "Branch to delete: $branch"
            remote_branch=$(echo ${branch} | sed 's#origin/##' )
            #git push origin --delete ${remote_branch}
            branches_to_delete+=("$branch")
          else
            echo "Branch created after threshold date: $branch"
          fi
        done
        for branch in "${branches_to_delete[@]}"; do
          echo "Branch to delete: $branch"
        done
