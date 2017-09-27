# Login to the Data Lake using a context file
function Perform-AdlLogin ([string] $contextPath)
{
 $contextFileExists = Test-Path $contextPath

 Write-Output "Logging in"

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

# Creates a new file or folder in the Data Lake
function Add-ItemToDataLake
([string] $accountName, 
 [string] $contextPath,
 [string] $newItemName,
 [bool] $isFolder 
)
{
 Perform-AdlLogin($contextPath)

 if ($isFolder)
 {
  Write-Output "Creating folder..."
  New-AzureRmDataLakeStoreItem -Account $accountName -Path $newItemName -Folder -Force
 }
 else
 {
 Write-Output "Creating file..."
 New-AzureRmDataLakeStoreItem -Account $accountName -Path $newItemName -Force
 }
}

#Add-ItemToDataLake "sqlservercentral" "c:\temp\azurecontext.json" "/testfolder1/testfolder2/testfolder3" $true
#Add-ItemToDataLake "sqlservercentral" "c:\temp\azurecontext.json" "/testfile.txt" $false

# Uploads the specified folder to the specified Data Lake account
function Upload-ItemToDataLake
([string] $accountName,
  [string] $contextPath,
  [string] $localSourceItem,
  [string] $remoteTargetItem)
{ 
 if (([string]::IsNullOrEmpty($accountName)) -Or
     ([string]::IsNullOrEmpty($contextPath)) -Or
     ([string]::IsNullOrEmpty($localSourceItem)) -Or
     ([string]::IsNullOrEmpty($remoteTargetItem)))
 {
  Write-Output "All options are mandatory. Usage: Upload-ItemToDataLake ""accountname"" ""contextPath"" ""localSourceItem"" ""remoteTargetItem"""
 }
 else
 {
  Perform-AdlLogin($contextPath)
  
  # Import data
  Write-Output "Uploading data..."
  Import-AdlStoreItem -Account $accountName -Path $localSourceItem -Destination $remoteTargetItem -Force
  Write-Output "Successfully uploaded $localSourceItem to $remoteTargetItem"
 }
}

#Upload-ItemToDataLake "sqlservercentral" "c:\temp\azurecontext.json" "C:\temp\sampledata" "/new_sample_data"

function Download-ItemFromDataLake([string] $accountName, [string] $contextPath, 
[string] $remoteSourcePath, [string] $localTargetPath)
{
 Perform-AdlLogin($contextPath)
 Export-AzureRmDataLakeStoreItem -Account $accountName -Path $remoteSourcePath -Destination $localTargetPath -Force -Recurse
}

#Download-ItemFromDataLake "sqlservercentral" "c:\temp\azurecontext.json" "/all_sample_data" "c:\temp\downloaded_data\all"

function Move-DataLakeItem([string] $accountName, [string] $contextPath, [string] $sourceItemPath, [string] $targetItemPath)
{
 Perform-AdlLogin($contextPath)
 Move-AzureRmDataLakeStoreItem -Account $accountName -Path $sourceItemPath -Destination $targetItemPath -Force
}

#Move-DataLakeItem "sqlservercentral" "c:\temp\azurecontext.json" "/processed/ssc_uk_postcodes" "/ssc_uk_postcodes"

function Delete-DataLakeItem([string] $accountName, [string] $contextPath, [string] $pathToDelete)
{
 Perform-AdlLogin($contextPath)

 $pathExists = Test-AdlStoreItem -Account $accountName -Path $pathToDelete

 if ($pathExists)
 {
  Remove-AzureRmDataLakeStoreItem -Account $accountName -Paths $pathToDelete -Force -Recurse
  Write-Output "Deleted $pathToDelete"
 }
 else
 {
  Write-Output "The specified file or folder does not exist."
 }
}

#Delete-DataLakeItem "sqlservercentral" "c:\temp\azurecontext.json" "/all_sample_data"