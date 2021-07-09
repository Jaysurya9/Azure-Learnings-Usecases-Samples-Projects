# Azure Automation Windows and Linux Update Summary


<h2>Azure Automation Windows Update Summary for All Subscriptions</h2>

<h4>KQL - Log Analytics - Log Query</h4>

    Update
    | where TimeGenerated>ago(14h) and OSType!="Linux" and (Optional==false or Classification has "Critical" or Classification has "Security") 
    and SourceComputerId in ((Heartbeat
    | where TimeGenerated>ago(12h) and OSType=~"Windows" and notempty(Computer)
    | summarize arg_max(TimeGenerated, Solutions) by SourceComputerId
    | where Solutions has "updates" | distinct SourceComputerId))
    | summarize hint.strategy=partitioned arg_max(TimeGenerated, *) by Computer, SourceComputerId, UpdateID
    | where UpdateState=~"Needed" and Approved!=false
    | summarize UpdatesNeeded=count(Classification) by Classification

<h2>Azure Automation Linux Update Summary for All Subscriptions</h2>

<h4>KQL - Log Analytics - Log Query</h4>
    
    Update
    | where TimeGenerated>ago(5h) and OSType=="Linux"
    | summarize hint.strategy=partitioned arg_max(TimeGenerated, UpdateState, Classification) by Computer, SourceComputerId, Product, ProductArch
    | where UpdateState=~"Needed"
    | summarize by Product, ProductArch, Classification, Computer
    | summarize count(Classification) by Classification
    
<h2>Heatmap of Update Summary by Computer</h2>

<h4>KQL - Log Analytics - Log Query</h4>

    Heartbeat
    | where TimeGenerated>ago(12h) and OSType=="Linux" and notempty(Computer)
    | summarize arg_max(TimeGenerated, Solutions, Computer, ResourceId, ComputerEnvironment, VMUUID) by SourceComputerId
    | where Solutions has "updates"
    | extend vmuuId=VMUUID, azureResourceId=ResourceId, osType=1, environment=iff(ComputerEnvironment=~"Azure", 1, 2), scopedToUpdatesSolution=true, lastUpdateAgentSeenTime=""
    | join kind=leftouter
    (
        Update
        | where TimeGenerated>ago(5h) and OSType=="Linux" and SourceComputerId in ((Heartbeat
        | where TimeGenerated>ago(12h) and OSType=="Linux" and notempty(Computer)
        | summarize arg_max(TimeGenerated, Solutions) by SourceComputerId
        | where Solutions has "updates"
        | distinct SourceComputerId))
        | summarize hint.strategy=partitioned arg_max(TimeGenerated, UpdateState, Classification, Product, Computer, ComputerEnvironment) by SourceComputerId, Product, ProductArch
        | summarize Computer=any(Computer), ComputerEnvironment=any(ComputerEnvironment), missingCriticalUpdatesCount=countif(Classification has "Critical" and UpdateState=~"Needed"), missingSecurityUpdatesCount=countif(Classification has "Security" and UpdateState=~"Needed"), missingOtherUpdatesCount=countif(Classification !has "Critical" and Classification !has "Security" and UpdateState=~"Needed"), lastAssessedTime=max(TimeGenerated), lastUpdateAgentSeenTime="" by SourceComputerId
        | extend compliance=iff(missingCriticalUpdatesCount > 0 or missingSecurityUpdatesCount > 0, 2, 1)
        | extend ComplianceOrder=iff(missingCriticalUpdatesCount > 0 or missingSecurityUpdatesCount > 0 or missingOtherUpdatesCount > 0, 1, 3)
    )
    on SourceComputerId
    | project id=SourceComputerId, displayName=Computer, sourceComputerId=SourceComputerId, scopedToUpdatesSolution=true, missingCriticalUpdatesCount=coalesce(missingCriticalUpdatesCount, -1), missingSecurityUpdatesCount=coalesce(missingSecurityUpdatesCount, -1), missingOtherUpdatesCount=coalesce(missingOtherUpdatesCount, -1), compliance=coalesce(compliance, 4), lastAssessedTime, lastUpdateAgentSeenTime, osType=1, environment=iff(ComputerEnvironment=~"Azure", 1, 2), ComplianceOrder=coalesce(ComplianceOrder, 2)
    | union(Heartbeat
    | where TimeGenerated>ago(12h) and OSType=~"Windows" and notempty(Computer)
    | summarize arg_max(TimeGenerated, Solutions, Computer, ResourceId, ComputerEnvironment, VMUUID) by SourceComputerId
    | where Solutions has "updates"
    | extend vmuuId=VMUUID, azureResourceId=ResourceId, osType=2, environment=iff(ComputerEnvironment=~"Azure", 1, 2), scopedToUpdatesSolution=true, lastUpdateAgentSeenTime=""
    | join kind=leftouter
    (
        Update
        | where TimeGenerated>ago(14h) and OSType!="Linux" and SourceComputerId in ((Heartbeat
        | where TimeGenerated>ago(12h) and OSType=~"Windows" and notempty(Computer)
        | summarize arg_max(TimeGenerated, Solutions) by SourceComputerId
        | where Solutions has "updates"
        | distinct SourceComputerId))
        | summarize hint.strategy=partitioned arg_max(TimeGenerated, UpdateState, Classification, Title, Optional, Approved, Computer, ComputerEnvironment) by Computer, SourceComputerId, UpdateID
        | summarize Computer=any(Computer), ComputerEnvironment=any(ComputerEnvironment), missingCriticalUpdatesCount=countif(Classification has "Critical" and UpdateState=~"Needed" and Approved!=false), missingSecurityUpdatesCount=countif(Classification has "Security" and UpdateState=~"Needed" and Approved!=false), missingOtherUpdatesCount=countif(Classification !has "Critical" and Classification !has "Security" and UpdateState=~"Needed" and Optional==false and Approved!=false), lastAssessedTime=max(TimeGenerated), lastUpdateAgentSeenTime="" by SourceComputerId
        | extend compliance=iff(missingCriticalUpdatesCount > 0 or missingSecurityUpdatesCount > 0, 2, 1)
        | extend ComplianceOrder=iff(missingCriticalUpdatesCount > 0 or missingSecurityUpdatesCount > 0 or missingOtherUpdatesCount > 0, 1, 3)
    )
    on SourceComputerId
    | project id=SourceComputerId, displayName=Computer, sourceComputerId=SourceComputerId, scopedToUpdatesSolution=true, missingCriticalUpdatesCount=coalesce(missingCriticalUpdatesCount, -1), missingSecurityUpdatesCount=coalesce(missingSecurityUpdatesCount, -1), missingOtherUpdatesCount=coalesce(missingOtherUpdatesCount, -1), compliance=coalesce(compliance, 4), lastAssessedTime, lastUpdateAgentSeenTime, osType=2, environment=iff(ComputerEnvironment=~"Azure", 1, 2), ComplianceOrder=coalesce(ComplianceOrder, 2) )
    | order by ComplianceOrder asc, missingCriticalUpdatesCount desc, missingSecurityUpdatesCount desc, missingOtherUpdatesCount desc, displayName asc
    | project displayName, scopedToUpdatesSolution, CriticalUpdates=missingCriticalUpdatesCount, SecurityUpdates=missingSecurityUpdatesCount, OtherUpdates=missingOtherUpdatesCount, compliance, osType, Environment=environment, lastAssessedTime, lastUpdateAgentSeenTime
    | extend osType = replace(@"2", @"Windows", tostring(osType))
    | extend osType = replace(@"1", @"Linux", tostring(osType))
    | extend Environment = replace(@"2", @"Non-Azure", tostring(Environment))
    | extend Environment = replace(@"1", @"Azure", tostring(Environment))
    
