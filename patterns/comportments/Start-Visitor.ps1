class Visitor {
    [scriptblock]$Visit
}

# Define a file system element
function New-FileSystemElement {
    param (
        [string]$Name,
        [string]$Type, # "File" or "Directory"
        [int]$Size
    )
    @{
        Name   = $Name
        Type   = $Type
        Size   = $Size
        Accept = {
            param ([Visitor]$Visitor)
            $Visitor.Visit.Invoke($this)
        }
    }
}

# Define the Visitor
class NewVisitor : Visitor {
    NewVisitor(
        [ScriptBlock]$Visit
    ) {
        $this.Visit = $Visit
    }
}

# Example 1: A visitor to display element details
[Visitor]$DisplayVisitor = [NewVisitor]::new({
        param ($Element)
        if ($Element.Type -eq "File") {
            Write-Output "File: $($Element.Name), Size: $($Element.Size) KB"
        }
        elseif ($Element.Type -eq "Directory") {
            Write-Output "Directory: $($Element.Name)"
        }
    })

# Example 2: A visitor to calculate total size of files
$TotalSize = 0
$SizeCalculatorVisitor = [NewVisitor]::new({
    param ($Element)
    if ($Element.Type -eq "File") {
        $script:TotalSize += $Element.Size
    }
})

# Create file system elements
$File1 = New-FileSystemElement -Name "File1.txt" -Type "File" -Size 150
$File2 = New-FileSystemElement -Name "File2.txt" -Type "File" -Size 300
$Directory = New-FileSystemElement -Name "Documents" -Type "Directory" -Size 0

# A list of elements to iterate over
$Elements = @($File1, $File2, $Directory)

# Use the DisplayVisitor
Write-Output "Displaying file system elements:"
foreach ($Element in $Elements) {
    $Element.Accept.Invoke($DisplayVisitor)
}

# Use the SizeCalculatorVisitor
Write-Output "`nCalculating total file size:"
foreach ($Element in $Elements) {
    $Element.Accept.Invoke($SizeCalculatorVisitor)
}
Write-Output "Total size of files: $TotalSize KB"
