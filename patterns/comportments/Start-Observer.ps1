class Observer {
    [void] Update([Subject]$subject) {}
}

class Subject {
    $observers = [System.Collections.Generic.List[Observer]]::new()
    [void] Attach ([Observer]$observer) {
        if ($this.observers.Contains($observer)) {
            Write-Host "[Subject]: Observer $observer already attached" -ForegroundColor Cyan
            return
        }
        Write-Host "[Subject]: Observer $observer attached" -ForegroundColor Cyan
        $this.observers += $observer
    }

    [void] Detach ([Observer]$observer) {
        $this.observers = ($this.observers | Where-Object { $_ -ne $observer })
        Write-Host "[Subject]: Observer $observer detached" -ForegroundColor Cyan
    }

    [void] Notify() {
        foreach ($observer in $this.observers) {
            $observer.Update($this)
        }
    }
}



function Start-Observer {
    param()
    process {
        class Concrete : Subject {
            [int]$value = 10;
            
            [void] SomeLogic() {
                $this.value = (Get-Random -Minimum 0 -Maximum 100)
                $this.Notify()
            }
        }
        class ObserverA : Observer {
            [void] Update([Subject]$subject) {
                Write-Host " > [ObserverA]: Subject value is $($subject.value)" -ForegroundColor DarkCyan
            }
        }
        class ObserverB : Observer {
            [void] Update([Subject]$subject) {
                if ($subject.value -gt 50) {
                    Write-Host " > [ObserverB]: Subject value  $($subject.value) is greater than 50" -ForegroundColor DarkGray
                }
            }
        }
 
        $subject = [Concrete]::new()
        $observerA = [ObserverA]::new()
        $observerB = [ObserverB]::new()
        
        $subject.Attach($observerA)
        $subject.Attach($observerB)
        
        $subject.SomeLogic()
        $subject.Attach($observerA)

        $subject.SomeLogic()
        $subject.SomeLogic()
        $subject.Detach($observerA)

        $subject.SomeLogic()

        $subject
    }
}

