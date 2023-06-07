#App Deployment Script
#6-7-23
function Deploy-Application{
    param(
        [Parameter(mandatory = $true)]
        [string] $app,
        [Parameter(mandatory = $true)]
        [string[]] $collections,
        [string] $oldApp,
        [switch]$immediate
    )
    $date = Get-Date
    if(!$immediate){$date = "$($date.month)/$($date.day)/$($date.year) 19:00:00"}
    
    foreach($collection in $collections){
        if($oldApp){
            Remove-CMDeployment -ApplicationName $oldApp -CollectionName $collection -Force
        }
        New-CMApplicationDeployment -Name $app  -CollectionName $collection -TimeBaseOn LocalTime -DeadlineDateTime $date `
        -DeployAction Install -DeployPurpose Required -OverrideServiceWindow $true 
    }
    $DPGroups = @("Source Distribution Points", "Pull Distribution Points", "Standard Distribution Points")
    foreach($group in $DPGroups){
        try{
        Start-CMContentDistribution -DistributionPointGroupName $group
        }catch{write-host "Unable to distribute to $($group)"} #content already deployed / invalid group name
    }
}


#Edge Collections Example
$collections = @("Workstations | Group A", "Workstations | Group B", "Workstations | Group C", "Workstations | Group D")
#App to be replaced
$oldApp = "Microsoft Edge 112" 
#New app to be deployed
$app = "Microsoft Edge 113" 

#Immediate deployment with app replacement Example
#Deploy-Application -app $app -oldApp $oldApp -collections $collections -immediate

#7PM deployment without application replacement
Deploy-Application -app $app -collections $collections -oldApp $oldApp
