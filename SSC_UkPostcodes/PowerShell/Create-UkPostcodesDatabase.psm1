# Login to the Data Lake using a context file
function Perform-AdlLogin ([string] $contextPath)
{
 $contextFileExists = Test-Path $contextPath

 Write-Output "Logging in using $contextPath"

 Try
 {
  if ($contextFileExists)
  {
   # Login to Azure using saved context
   Import-AzureRmContext -Path $contextPath
  }
  else
  {
   Write-Output "The context file does not exist: $contextPath"
   break
  }
 }
 Catch
 {
  Write-Output "Logging in from context file failed - check your context file."
  break
 }
}

function Execute-Script ([string] $accountName, [string] $scriptPath, [string] $scriptName, [string] $dbName)
{
 $dbScript = -join($scriptPath, $scriptName)
 $currentJob = Submit-AdlJob -Account $accountName -ScriptPath $dbScript -Name "Execute $scriptName"
 Wait-AdlJob -Account $accountName -JobId $currentJob.JobId
}

function Drop-Database ([string] $accountName, [string] $dbName)
{
 $dbExists = Test-AdlCatalogItem -Account $accountName -ItemType Database -Path $dbName
 
 # Drop the database if it exists
 if ($dbExists)
 {
  Write-Output "$dbName database already exists...dropping"
  $dropScript = "USE master; DROP DATABASE IF EXISTS $dbName;"
  $dropDbJob = Submit-AdlJob -Account $accountName -Script $dropScript -Name "Drop $dbName Database"
  Wait-AdlJob -Account $accountName -JobId $dropDbJob.JobId
 }
}

function Create-Database([string] $accountName, [string] $contextPath, [string] $dbName)
{
 $scriptPath = "C:\Users\Mike McQuillan\source\repos\usql_ssc\SSC_UkPostcodes\"

 Perform-AdlLogin $contextPath

 Drop-Database $accountName $dbName

 Write-Output "Creating objects..."

 Execute-Script $accountName $scriptPath "010 Create UkPostcodes Database.usql" $dbName
 Execute-Script $accountName $scriptPath "020 Create Postcodes Schema.usql" $dbName
 Execute-Script $accountName $scriptPath "030 Create Counties Table.usql" $dbName
 Execute-Script $accountName $scriptPath "040 Create Districts Table.usql" $dbName
 Execute-Script $accountName $scriptPath "050 Create PostcodeEstimates Table.usql" $dbName
 Execute-Script $accountName $scriptPath "060 Create Postcodes Table.usql" $dbName

 Write-Output "Database creation complete."
}
