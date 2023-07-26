function Split-CsvFile {
    param(
        [string]$inputFile,
        [string]$outputDirectory,
        [int]$maxLines = 65000
    )

    try {
        $csv = Import-Csv $inputFile
    } catch {
        Write-Host "Error: Unable to import CSV file."
        return
    }

    if ($csv -eq $null -or $csv.Count -eq 0) {
        Write-Host "Error: The CSV file is empty or invalid."
        return
    }

    $rowThresholdForWarning = 100000
    if ($csv.Count -ge $rowThresholdForWarning) {
        Write-Host "Warning: This task may take a long time on a very large CSV file with $($csv.Count) rows."
    }

    $header = $csv[0].PSObject.Properties.Name

    $fileIndex = 1
    $lineCount = 0
    $outputFile = Join-Path $outputDirectory "output$fileIndex.csv"
    $output = @()

    $timer = Measure-Command {
        foreach ($row in $csv) {
            $output += $row
            $lineCount++

            if ($lineCount -eq $maxLines) {
                $output | Export-Csv -Path $outputFile -NoTypeInformation
                $fileIndex++
                $lineCount = 0
                $output = @()
                $outputFile = Join-Path $outputDirectory "output$fileIndex.csv"
                $output += $header
            }
        }

        # Export the remaining data (if any) to the last file
        if ($output.Count -gt 0) {
            $output | Export-Csv -Path $outputFile -NoTypeInformation
        }
    }

    Write-Host "Task completed in $($timer.TotalSeconds) seconds."
}

# Usage example:
$inputFile = "C:\path\to\your\largefile.csv"
$outputDirectory = "C:\path\to\output\directory"
Split-CsvFile -inputFile $inputFile -outputDirectory $outputDirectory
