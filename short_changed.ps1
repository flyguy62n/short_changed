[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Path to a ShortKeys text file or directory containing text files")]
    [string]$Path,
    
    [Parameter(Mandatory=$false, HelpMessage="Output CSV file path. If not specified, uses input filename with .csv extension")]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false, HelpMessage="Process all .txt files in directory")]
    [switch]$Directory,
    
    [Parameter(Mandatory=$false, HelpMessage="Character to prepend to each abbreviation (default: semicolon)")]
    [string]$PrefaceChar = ";"
)

function Convert-ShortKeysToCSV {
    param(
        [string]$InputFile,
        [string]$OutputFile,
        [string]$PrefaceChar
    )
    
    Write-Host "Processing: $InputFile"
    
    # Read the entire file
    $content = Get-Content -Path $InputFile -Raw
    
    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Warning "File is empty: $InputFile"
        return
    }
    
    # Split content by the ITEM NAME pattern (without requiring any specific prefix character)
    $pattern = '<ITEM NAME>'
    $sections = $content -split $pattern
    
    # Create collection for CSV rows
    $csvRows = @()
    
    foreach ($section in $sections) {
        # Skip empty sections
        if ([string]::IsNullOrWhiteSpace($section)) {
            continue
        }
        
        # Split section into lines
        $lines = $section -split "`r?`n"
        
        if ($lines.Count -eq 0) {
            continue
        }
        
        # First line is the trigger/abbreviation
        # Strip any leading special characters from the original format (e.g., $)
        # Then prepend the user's chosen preface character
        $rawAbbreviation = $lines[0].Trim()
        $cleanAbbreviation = $rawAbbreviation -replace '^\W+', ''  # Remove leading non-word characters
        $abbreviation = $PrefaceChar + $cleanAbbreviation
        
        if ([string]::IsNullOrWhiteSpace($cleanAbbreviation)) {
            continue
        }
        
        # Remaining lines are the snippet (replacement text)
        # Join all remaining lines, preserving line breaks
        $snippetLines = $lines[1..($lines.Count - 1)]
        $snippet = ($snippetLines -join "`n").Trim()
        
        # Escape double quotes by doubling them
        $snippet = $snippet -replace '"', '""'
        
        # Create CSV row object
        $csvRows += [PSCustomObject]@{
            abbreviation = $abbreviation
            snippet = $snippet
        }
    }
    
    Write-Host "Found $($csvRows.Count) shortcuts"
    
    if ($csvRows.Count -eq 0) {
        Write-Warning "No shortcuts found in: $InputFile"
        return
    }
    
    # Export to CSV
    # We need to manually construct the CSV to ensure proper quote handling for multi-line content
    $csv = New-Object System.Text.StringBuilder
    
    # Add each row (no header - TextExpander doesn't expect one)
    foreach ($row in $csvRows) {
        # Enclose snippet in quotes (required for multi-line)
        $line = "$($row.abbreviation),`"$($row.snippet)`""
        [void]$csv.AppendLine($line)
    }
    
    # Write to file
    $csv.ToString() | Out-File -FilePath $OutputFile -Encoding UTF8 -NoNewline
    
    Write-Host "Successfully created: $OutputFile" -ForegroundColor Green
}

# Main script logic
try {
    # Check if path exists
    if (-not (Test-Path -Path $Path)) {
        throw "Path not found: $Path"
    }
    
    $pathItem = Get-Item -Path $Path
    
    if ($pathItem.PSIsContainer -or $Directory) {
        # Process directory
        Write-Host "Processing directory: $Path"
        
        $txtFiles = Get-ChildItem -Path $Path -Filter "*.txt" -File
        
        if ($txtFiles.Count -eq 0) {
            Write-Warning "No .txt files found in: $Path"
            return
        }
        
        Write-Host "Found $($txtFiles.Count) text file(s)"
        
        foreach ($file in $txtFiles) {
            $outputFile = [System.IO.Path]::ChangeExtension($file.FullName, ".csv")
            Convert-ShortKeysToCSV -InputFile $file.FullName -OutputFile $outputFile -PrefaceChar $PrefaceChar
            Write-Host ""
        }
    }
    else {
        # Process single file
        if ($OutputPath) {
            $outputFile = $OutputPath
        }
        else {
            $outputFile = [System.IO.Path]::ChangeExtension($Path, ".csv")
        }
        
        Convert-ShortKeysToCSV -InputFile $Path -OutputFile $outputFile -PrefaceChar $PrefaceChar
    }
    
    Write-Host "`nConversion complete!" -ForegroundColor Green
}
catch {
    Write-Error "Error: $_"
    exit 1
}
