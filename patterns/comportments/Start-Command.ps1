# Define the ICommand interface
class ICommand {
    [void] Execute() {}
    [void] Undo() {}
}

# Concrete Command to create a file
class CreateFileCommand : ICommand {
    [string]$FilePath
    [string]$Content
    [string]$CommandName = "CreateFileCommand"

    CreateFileCommand([string]$filePath, [string]$content) {
        $this.FilePath = $filePath
        $this.Content = $content
    }
    
    [void] Execute() {
        Write-Output "Creating file: $($this.FilePath)"
        $this.Content | Set-Content -Path $this.FilePath
    }
    
    [void] Undo() {
        Write-Output "Deleting file: $($this.FilePath)"
        Remove-Item -Path $this.FilePath -Force
    }
}

# Concrete Command to write to an existing file
class WriteToFileCommand : ICommand {
    [string]$FilePath
    [string]$Content
    [string]$CommandName = "WriteToFileCommand"

    WriteToFileCommand([string]$filePath, [string]$content) {
        $this.FilePath = $filePath
        $this.Content = $content
    }

    [void] Execute() {
        Write-Output "Appending to file: $($this.FilePath)"
        $this.Content | Add-Content -Path $this.FilePath
    }

    [void] Undo() {
        Write-Output "Undo is not implemented for WriteToFileCommand"
    }
}

# Invoker to execute commands
class CommandInvoker {
    [System.Collections.ArrayList]$CommandHistory = @()

    [void] ExecuteCommand([ICommand]$command) {
        $command.Execute()
        $this.CommandHistory.Add(@{
                name    = $command.ToString();
                command = $command
            })
    }

    [void] UndoLastCommand() {
        if ($this.CommandHistory.Count -gt 0) {
            $lastCommand = $this.CommandHistory[$this.CommandHistory.Count - 1]
            Write-Host "Undoing command: " $lastCommand.name
            $lastCommand.command.Undo()
            $this.CommandHistory.RemoveAt($this.CommandHistory.Count - 1)
        }
        else {
            Write-Output "No commands to undo."
        }
    }
}
function Start-Command {
    
    # Usage Example
    $invoker = [CommandInvoker]::new()

    # Create and execute a CreateFileCommand
    $createCommand = [CreateFileCommand]::new(".\example.txt", "Hello, World!")
    $invoker.ExecuteCommand($createCommand)

    # Write to the file using WriteToFileCommand
    $writeCommand = [WriteToFileCommand]::new(".\example.txt", "This is an additional line.")
    $invoker.ExecuteCommand($writeCommand)

    # Undo the last command (WriteToFileCommand doesn't implement Undo)
    $invoker.UndoLastCommand()

    # Undo the CreateFileCommand (deletes the file)
    $invoker.UndoLastCommand()
}