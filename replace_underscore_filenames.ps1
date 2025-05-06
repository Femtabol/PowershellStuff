<#
.SYNOPSIS
    Finds files with underscores in their names and replaces the underscores with spaces.
.DESCRIPTION
    This script searches for files that have underscores in their filenames
    within a specified directory and renames them, replacing underscores with spaces.
    The search can be recursive if specified.
.PARAMETER Directory
    The directory path to search for files with underscores.
.PARAMETER Recursive
    Switch parameter to enable recursive search. Default is False.
.PARAMETER WhatIf
    Shows what would happen if the script runs without actually making changes.
.EXAMPLE
    .\Replace-UnderscoresWithSpaces.ps1 -Directory "C:\Documents" -Recursive
    Recursively searches and renames files with underscores in the C:\Documents directory.
.EXAMPLE
    .\Replace-UnderscoresWithSpaces.ps1 -Directory "D:\Data" -WhatIf
    Shows what files would be renamed in D:\Data without making actual changes.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Enter the directory path to search for files with underscores in their names.")]
    [ValidateNotNullOrEmpty()]
    [string]$Directory,

    [Parameter(Mandatory=$false, Position=1, HelpMessage="Specify if the search should be recursive.")]
    [switch]$Recursive
)

# Check if the directory exists
if (-not (Test-Path -Path $Directory)) {
    Write-Error "The specified directory does not exist: $Directory"
    return
}

# Resolve the directory path
$resolvedPath = Resolve-Path -Path $Directory -ErrorAction Stop

# Search for files with underscores in their names
Write-Verbose "Searching for files with underscores in $resolvedPath"
$searchParams = @{
    Path = $resolvedPath
    File = $true
    Filter = "*_*"
    Recurse = $Recursive
    ErrorAction = "SilentlyContinue"
}

$files = Get-ChildItem @searchParams

# Display and rename files
if ($files.Count -eq 0) {
    Write-Warning "No files with underscores found in $resolvedPath."
} else {
    Write-Output "Found $($files.Count) files with underscores."
    
    # Process each file to replace underscores with spaces
    foreach ($file in $files) {
        $directory = $file.DirectoryName
        $newName = $file.Name -replace "_", " "
        $newPath = Join-Path -Path $directory -ChildPath $newName
        
        # Check if a file with the new name already exists
        if (Test-Path -Path $newPath) {
            Write-Warning "Cannot rename '$($file.Name)' to '$newName'. A file with that name already exists."
        } else {
            # Rename the file
            if ($PSCmdlet.ShouldProcess($file.FullName, "Rename to $newName")) {
                try {
                    Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                    Write-Output "Renamed: '$($file.Name)' to '$newName'"
                } catch {
                    Write-Error "Failed to rename '$($file.Name)': $_"
                }
            }
        }
    }
}