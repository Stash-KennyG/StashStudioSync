# StashStudioSync
An easy way to query a stashbox GQL endpoint and import any unknown studio IDs.

## Requirements
- [PSGraphQL](https://github.com/anthonyg-1/PSGraphQL)
- [PSSQLite](https://github.com/RamblingCookieMonster/PSSQLite)
Requirements can be easily imported using Install Module commands in script.


## Config
Update the object at the beginning of the script with 
- your endpoint URL - defaults to StashDB
- your endpoint API Key
- the path of your stash SQLITE 

## Execution
Just run `./StudioSync.ps1`
