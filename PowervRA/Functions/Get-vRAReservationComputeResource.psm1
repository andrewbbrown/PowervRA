﻿function Get-vRAReservationComputeResource {
<#
    .SYNOPSIS
    Get a compute resource for a reservation type
    
    .DESCRIPTION
    Get a compute resource for a reservation type

    .PARAMETER Id
    The id of the compute resource
    
    .PARAMETER Name
    The name of the compute resource

    .INPUTS
    System.String

    .OUTPUTS
    System.Management.Automation.PSObject

    .EXAMPLE
    Get-vRAReservationComputeResource -Id 75ae3400-beb5-4b0b-895a-0484413c93b1

    .EXAMPLE
    Get-vRAReservationComputeResource -Name "Cluster01"

    .EXAMPLE
    Get-vRAReservationComputeResource

#>
[CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]

    Param (

    [parameter(Mandatory=$true,ParameterSetName="ById")]
    [ValidateNotNullOrEmpty()]
    [String[]]$Id,
    
    [parameter(Mandatory=$true,ParameterSetName="ByName")]
    [ValidateNotNullOrEmpty()]
    [String[]]$Name
       
    ) 
   
    DynamicParam {
    
        # --- Define the parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary           

        # --- Dynamic Param:Type
        $ParameterName = "Type"

        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.ParameterSetName = "__AllParameterSets"

        $AttributeCollection =  New-Object System.Collections.ObjectModel.Collection[System.Attribute]        
        $AttributeCollection.Add($ParameterAttribute)

        # --- Set the dynamic values
        $ValidateSetValues = Get-vRAReservationType | Select -ExpandProperty Name

        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSetValues)
        $AttributeCollection.Add($ValidateSetAttribute)
        
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    
        # --- Return the dynamic parameters
        return $RuntimeParameterDictionary    
    
    }
    
    begin {}
    
    process {   

        try {

            $SchemaClassId = (Get-vRAReservationType -Name $PSBoundParameters.Type).schemaClassId

            switch ($PsCmdlet.ParameterSetName) {

                'ById' { 

                    foreach ($ComputeResourceId in $Id) {

                        $URI = "/reservation-service/api/data-service/schema/$($SchemaClassId)/default/computeResource/values"
            
                        Write-Verbose -Message "Preparing POST to $($URI)"

                        $Response = Invoke-vRARestMethod -Method POST -URI "$($URI)" -Body "{}"

                        Write-Verbose -Message "SUCCESS"

                        # --- Get the compute resource by id
                        $ComputeResource = $Response.values | Where-Object {$_.underlyingValue.id -eq $ComputeResourceId}

                        if(!$ComputeResource) {

                            throw "Could not find compute resource with id $($ComputeResourceId)"

                        }

                        [pscustomobject] @{

                            Type = $ComputeResource.underlyingValue.type
                            ComponentId = $ComputeResource.underlyingValue.componentId
                            ClassId = $ComputeResource.underlyingValue.classId
                            Id = $ComputeResource.underlyingValue.id
                            Label = $ComputeResource.underlyingValue.label

                        }

                    }

                    break

                }

                'ByName' {

                    foreach ($ComputeResourceName in $Name) {

                        $URI = "/reservation-service/api/data-service/schema/$($SchemaClassId)/default/computeResource/values"
            
                        Write-Verbose -Message "Preparing POST to $($URI)"

                        $Response = Invoke-vRARestMethod -Method POST -URI "$($URI)" -Body "{}"

                        Write-Verbose -Message "SUCCESS"

                        # --- Get the compute resource by name
                        $ComputeResource = $Response.values | Where-Object {$_.underlyingValue.label -eq $ComputeResourceName}

                        if(!$ComputeResource) {

                            throw "Could not find compute resource with name $($ComputeResourceName)"

                        }

                        [pscustomobject] @{

                            Type = $ComputeResource.underlyingValue.type
                            ComponentId = $ComputeResource.underlyingValue.componentId
                            ClassId = $ComputeResource.underlyingValue.classId
                            Id = $ComputeResource.underlyingValue.id
                            Label = $ComputeResource.underlyingValue.label

                        }

                    }

                    break                                          
        
                }

                'Standard' {

                    $URI = "/reservation-service/api/data-service/schema/$($SchemaClassId)/default/computeResource/values"

                    Write-Verbose -Message "Preparing GET to $($URI)"

                    $Response = Invoke-vRARestMethod -Method POST -URI $URI -Body "{}"

                    # --- Return all compute resources
                    foreach ($ComputeResource in $Response.values) {

                        [pscustomobject] @{

                            Type = $ComputeResource.underlyingValue.type
                            ComponentId = $ComputeResource.underlyingValue.componentId
                            ClassId = $ComputeResource.underlyingValue.classId
                            Id = $ComputeResource.underlyingValue.id
                            Label = $ComputeResource.underlyingValue.label

                        }                
                
                    }            

                    break
    
                }

            }
           
        }
        catch [Exception]{
        
            throw

        }
        
    }   
     
}