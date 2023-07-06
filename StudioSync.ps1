#We need PSGraphQL since that's what Stash uses
Install-Module -Name PSGraphQL -Repository PSGallery -Scope CurrentUser
#We also need PSSQLite as that's what your local stash uses
Install-module -Name PSSQLite -Scope CurrentUser

$config = [ordered]@{
    API_endpoint = "https://stashdb.org/graphql"
    API_Key = ""
    StashDBLocation = "~\.stash\stash-go.sqlite"
}

#try to do some validation to make sure it was setup
if ($config.API_endpoint -eq "")
{
    $config.API_endpoint = Read-Host "Need the API Endpoint.  StashDB is likely https://stashdb.org/graphql"
}
if ($config.API_Key -eq "")
{
    $config.API_Key = Read-Host "You must input your API Key for $($config.api_endpoint)"
}
if ($config.StashDBLocation -eq "" || !(test-path $config.StashDBLocation))
{
    $config.StashDBLocation = Read-Host "Please input the full path to your stashdb sqlite file (~/.stash/stash-go.sqlite)"
}

$headers = @{APIKey="$($config.api_key)"}

#Find out the studios you don't have a matching ID for that endpoint yet
$query = "select * from studios s where id not in (select studio_id from studio_stash_ids ssi where ssi.endpoint = '$($config.API_endpoint)')"
$LocalStudios = Invoke-SqliteQuery -Query $Query -DataSource $config.StashDBLocation

#Loop
foreach ($studio in $localStudios)
{
    #Let's find the studio through graphQL
    $myQuery = "
    query MyQuery {
        findStudio(name: ""$($studio.name)"") {
          id
          name
        }
      }
    "
    
    $result = Invoke-GraphQLQuery -Query $myQuery -Uri $config.API_endpoint -Headers $headers
    #did we find anything?
    if ($result.data.findStudio)
    {
        #insert it into your database
        $query = "insert into studio_stash_ids (studio_id, endpoint, stash_id) values ($($studio.id), ""$($config.API_endpoint)"", ""$($result.data.findStudio.id)"")"
        Invoke-SqliteQuery -Query $Query -DataSource $config.StashDBLocation
        Write-Host "found $($studio.name) - $($result.data.findStudio.id)"
       
    }
    else {
        #We did not find that studio
        write-host "$($studio.name) not found" -ForegroundColor cyan
    }
}