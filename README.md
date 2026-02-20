# Short Changed

A PowerShell utility to convert ShortKeys text export files to TextExpander CSV format.

## Overview

This script reads ShortKeys text files and converts them to CSV format compatible with TextExpander. It processes the `<ITEM NAME>abbreviation` format used by ShortKeys and generates properly formatted CSV files with abbreviations and multi-line snippets.

## Features

- Process single files or entire directories
- Automatically strips leading special characters from original abbreviations
- Configurable preface character for transformed abbreviations
- Proper handling of multi-line snippets
- Automatic CSV quote escaping
- UTF-8 encoding support

## Installation

### Download the Script

1. Navigate to the [short_changed.ps1](https://github.com/flyguy62n/short_changed/blob/main/short_changed.ps1) file in this repository
2. Click the **Raw** button in the upper right corner of the file viewer
3. Right-click on the page and select **Save As**
4. Save the file as `short_changed.ps1`

### PowerShell Execution Policy

Since this script is unsigned, you may need to modify your PowerShell execution policy to run it. You have several options:

**Option 1: Bypass policy for this session only (recommended for testing)**
```powershell
powershell -ExecutionPolicy Bypass -File .\short_changed.ps1 -Path "input.txt"
```

**Option 2: Unblock the downloaded file**
```powershell
Unblock-File .\short_changed.ps1
```

**Option 3: Change execution policy for current user (permanent)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Option 4: Change execution policy for current session only**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

For more information about execution policies, run:
```powershell
Get-Help about_Execution_Policies
```

## Usage

### Basic Syntax

```powershell
.\short_changed.ps1 -Path <path> [-OutputPath <output>] [-Directory] [-PrefaceChar <char>]
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-Path` | Yes | - | Path to a ShortKeys text file or directory containing text files |
| `-OutputPath` | No | Auto-generated | Output CSV file path. If not specified, uses input filename with .csv extension |
| `-Directory` | No | False | Process all .txt files in the specified directory |
| `-PrefaceChar` | No | `;` | Character to prepend to each abbreviation (default: semicolon) |

### Examples

**Convert a single file with default settings:**
```powershell
.\short_changed.ps1 -Path "C:\Export\shortcuts.txt"
```
Output: `C:\Export\shortcuts.csv` with abbreviations like `;vpcwp`, `;rdcrouters`, etc.

**Convert with custom output location:**
```powershell
.\short_changed.ps1 -Path "shortcuts.txt" -OutputPath "textexpander_import.csv"
```

**Process all .txt files in a directory:**
```powershell
.\short_changed.ps1 -Path "C:\Export" -Directory
```
This creates a .csv file for each .txt file found in the directory.

**Use dollar sign as preface character:**
```powershell
.\short_changed.ps1 -Path "shortcuts.txt" -PrefaceChar "$"
```
Output abbreviations: `$vpcwp`, `$rdcrouters`, etc.

**Use no preface character:**
```powershell
.\short_changed.ps1 -Path "shortcuts.txt" -PrefaceChar ""
```
Output abbreviations: `vpcwp`, `rdcrouters`, etc.

## ShortKeys File Format

The script expects ShortKeys text files in the following format:

```
<ITEM NAME>$abbreviation1
Replacement text line 1
Replacement text line 2

Replacement text line 4
<ITEM NAME>$abbreviation2
More replacement text
...
```

**Note on Abbreviation Processing:**

The script automatically strips any leading special characters (like `$`, `;`, `!`, etc.) from the abbreviation in the source file before prepending your chosen `PrefaceChar`. This means:

- `<ITEM NAME>$abc123` with `-PrefaceChar ";"` → `;abc123`
- `<ITEM NAME>abc123` with `-PrefaceChar ";"` → `;abc123`
- `<ITEM NAME>!abc123` with `-PrefaceChar ";"` → `;abc123`

## TextExpander CSV Format

The generated CSV follows TextExpander's import format:
- Field order: `abbreviation,snippet`
- No header row
- Multi-line snippets enclosed in double quotes
- Double quotes within snippets are escaped as `""`

Example output:
```csv
;my_shortkey,"Line 1
Line 2
Line 3"
;abc123,"ABC
123"
```

## Importing into TextExpander

1. Export each of your ShortKeys files (Text Format) into a single folder
2. Run the script to generate your CSV file(s)
2. Open the TextExpander website
3. Click on "Import/Export"
4. Drag/drop the CSV files on to the import page

## Requirements

- Windows PowerShell 5.1 or later
- PowerShell Core 7.x or later

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.
