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

function Check-Database-Object-Exists
([string] $accountName, [string] $contextPath, [string] $databaseName, [string] $objectType, [string] $objectName)
{
 Perform-AdlLogin $contextPath
 
 $fullPath = "$($databaseName).$($objectName)"
 $ItemExists = Test-AdlCatalogItem -Account $accountName -ItemType $objectType -Path $fullPath

 return $ItemExists
}

function Get-Database-Info([string] $accountName, [string] $contextPath, [Parameter(Mandatory=$false)][string] $databaseName)
{
 Write-Output $contextPath
 Perform-AdlLogin $contextPath

 if (!$databaseName)
 {
  $databases = Get-AdlCatalogItem -Account $accountName -ItemType Database
 }
 else
 {
  $databases = Get-AdlCatalogItem -Account $accountName -ItemType Database -Path $databaseName
 }

 foreach ($db in $databases)
 {
  Write-Output "DATABASE NAME: $($db.Name)"
  Write-Output "BELONGS TO ACCOUNT: $($db.ComputeAccountName)"
  Write-Output "----------"
  Write-Output "SCHEMAS"
  Write-Output "----------"
  
  $schemas = Get-AdlCatalogItem -Account $accountName -ItemType Schema -Path $db.Name

  foreach ($schema in $schemas)
  {
   Write-Output $schema.Name
  }

  Write-Output ""
  Write-Output "----------"
  Write-Output "TABLES"
  Write-Output "----------"
  
  $tables = Get-AdlCatalogItem -Account $accountName -ItemType Table -Path $db.Name

  foreach ($table in $tables)
  {
   Write-Output "TABLE NAME: $($table.Schema).$($table.Name)"
   Write-Output "COLUMN COUNT: $($table.ColumnList.Count)"
   Write-Output ""
  }

  Write-Output "----------"
  Write-Output "TABLE VALUED FUNCTIONS"
  Write-Output "----------"
  
  $functions = Get-AdlCatalogItem -Account $accountName -ItemType TableValuedFunction -Path $db.Name

  foreach ($function in $functions)
  {
   Write-Output "FUNCTION NAME: $($function.SchemaName).$($function.Name)"
   #Write-Output "CODE: $($function.Definition)"
   Write-Output ""
  }

  Write-Output "----------"
  Write-Output "PROCEDURES"
  Write-Output "----------"

  foreach ($schema in $schemas)
  {
   $path = "$($db.Name).$($schema.Name)"
   $procs = Get-AdlCatalogItem -Account $accountName -ItemType Procedure -Path $path

   foreach ($proc in $procs)
   {
    Write-Output "PROC NAME: $($proc.SchemaName).$($proc.Name)"
    #Write-Output "CODE: $($proc.Definition)"
   }
  }
 }
}

#Check-Database-Object-Exists "sqlservercentral" "C:\temp\ssc_2018\azurecontext.json" "UkPostcodes" "Table" "IDontExist"
#Get-Database-Info "sqlservercentral" "C:\temp\ssc_2018\azurecontext.json" "UkPostcodes"