<h1>Azure Virtual Machine Performance Reports</h1>

<b>VM CPU and MEMORY Utilization - across all computers by OSType = "Windows/Linux"</b>
    
    Perf
    | where TimeGenerated > ago(30d)
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where Computer in ((Heartbeat | where OSType == "Linux" or OSType == "Windows" | distinct Computer))
    | summarize MIN_CPU = min(CounterValue), AVG_CPU = avg(CounterValue), MAX_CPU = max(CounterValue) by Computer
    | join 
    ( 
    Perf 
    | where ObjectName == "Memory"
    | where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use"
    | where TimeGenerated > ago(30d)
    | summarize MIN_MEMORY = min(CounterValue), AVG_MEMOERY= avg(CounterValue), MAX_MEMORY = max(CounterValue) by Computer
    ) on Computer
    
   or
   
    Perf
    | where CounterName == "% Processor Time"  and InstanceName == "_Total"
    | where TimeGenerated > ago(30d)
    | project bin(TimeGenerated, 30d), Computer, CPU=(CounterValue), _ResourceId, Type, SourceSystem
    | join (
       Perf
        | where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" 
        | where TimeGenerated > ago(30d)
        | project bin(TimeGenerated, 30d), Computer, MEMORY=CounterValue, _ResourceId, Type, SourceSystem
    ) on TimeGenerated, Computer
    | summarize MIN_CPU=min(CPU), AVG_CPU=avg(CPU), MAX_CPU=max(CPU), MIN_MEMORY=min(MEMORY), AVG_MEMORY=avg(MEMORY), MAX_MEMORY=max(MEMORY) 
    by Computer, _ResourceId, Type = "Performance" , SourceSystem
    

<b>VM CPU Utilization - MIN,AVG, MAX across all computers by OSType = "Windows"</b>

    Perf
    | where TimeGenerated > ago(30d)
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where Computer in ((Heartbeat | where OSType == "Windows" | distinct Computer))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = max(CounterValue) by Computer, _ResourceId


<b>VM CPU Utilization - MIN,AVG, MAX across all computers by OSType = "Linux"</b>    

    Perf
    | where TimeGenerated > ago(30d)
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where Computer in ((Heartbeat | where OSType == "Linux" | distinct Computer))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = max(CounterValue) by Computer, _ResourceId
    
    
<b>VM CPU Utilization - MIN,AVG, MAX across all computers by OSType = "Windows/Linux"</b> 

    Perf
    | where TimeGenerated > ago(30d)
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where Computer in ((Heartbeat | where OSType == "Linux" or OSType == "Windows" | distinct Computer))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = max(CounterValue) by Computer, _ResourceId
    

<b> VM CPU and Memory Utilization, VM Available Memory across all Computers with VM Details</b>
    
    InsightsMetrics
    | where Origin == "vm.azm.ms" 
    | where Namespace == "Processor" and Name == "UtilizationPercentage" 
    | summarize AVG_CPU=avg(Val), MIN_CPU=min(Val), MAX_CPU=max(Val) by bin(TimeGenerated, 30d), Computer
    | join 
    (
    InsightsMetrics
    | where Origin == "vm.azm.ms"
    | where Namespace == "Memory" and Name == "AvailableMB"
    | summarize Avg_AvailableMemory=avg(Val), Min_AvailableMemory=min(Val), Max_AvailableMemory=max(Val) by bin(TimeGenerated, 30d), Computer 
    ) on Computer
    | join 
    (
       Perf
        | where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" 
        | summarize AVG_MEM=avg(CounterValue), MIN_MEM=min(CounterValue), MAX_MEM=max(CounterValue) by bin(TimeGenerated, 30d), Computer
    ) on Computer
    | join
    (
    VMComputer 
    | summarize by Computer, AzureImageOffering, AzureLocation, AzureImageSku, 
    OperatingSystemFamily, VirtualMachineNativeName, VirtualMachineType, DisplayName, HostName,  AzureResourceName, AzureSubscriptionId, AzureResourceGroup, OperatingSystemFullName, Cpus, AzureSize, AzureImagePublisher, AzureImageVersion) on Computer
    | project HostName, AzureResourceGroup, Computer, OperatingSystemFamily, OperatingSystemFullName, AzureSize, Cpus, MIN_CPU, AVG_CPU, MAX_CPU, 
    MIN_MEM, AVG_MEM, MAX_MEM, 
    Min_AvailableMemory, Avg_AvailableMemory, Max_AvailableMemory


//Average CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize AVGCPU = avg(CounterValue) by Computer, InstanceName, _ResourceId
    
   or
   
    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where TimeGenerated > ago(30d) 
    | summarize AVGCPU = avg(CounterValue) by Computer, InstanceName, _ResourceId


//Minimum CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MINCPU = min(CounterValue) by Computer, InstanceName, _ResourceId
    
   or 
    
    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where TimeGenerated > ago(30d) 
    | summarize MINCPU = min(CounterValue) by Computer, InstanceName, _ResourceId
    

//Maximum CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MAXCPU = min(CounterValue) by Computer
   
   or 
    
    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where TimeGenerated > ago(30d) 
    | summarize MAXCPU = min(CounterValue) by Computer, InstanceName, _ResourceId
    

//Min, Max, Avg CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = min(CounterValue) by Computer
    
   or
   
    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
    | where TimeGenerated > ago(30d) 
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = min(CounterValue) by Computer, InstanceName, _ResourceId


//Virtual Machine free disk space per instance / all computers

    Perf 
    | where ObjectName == "LogicalDisk" or ObjectName == "Logical Disk"
    | where CounterName == "Free Megabytes"
    | summarize arg_max(TimeGenerated, *) by InstanceName 
    | project Computer, InstanceName, Free Megabytes = CounterValue, TimeGenerated


//Virtual Machine available memory across all computers by TimeGenerated

    Perf
    | where ObjectName == "Memory" and (CounterName == "Available MBytes Memory" or CounterName == "Available MBytes") 
    | summarize AvailableMBytes = avg(CounterValue) by Computer, bin(TimeGenerated, 30d)


//CPU Utilization Above 60% and below 70% across all computers by TimeGenerated

    Perf
    | where CounterName == "% Processor Time" and ObjectName == "Processor"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = max(CounterValue) by Computer
    | where AggregatedValue between ( 60 .. 70)


//CPU Utilization Above 70% across all computers by TimeGenerated

    Perf
    | where CounterName == "% Processor Time" and ObjectName == "Processor"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = max(CounterValue) by Computer
    | where AggregatedValue >=70%


//Memory Utilization Above 60% and below 70% across all computers by TimeGenerated

    Perf
    | where ObjectName == 'Memory' and CounterName == "% Used Memory"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = max(CounterValue) by Computer
    | where AggregatedValue between ( 60 .. 70 )


//Memory Utilization Above 70% across all computers by TimeGenerated

    Perf
    | where ObjectName == 'Memory' and CounterName == "% Used Memory"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = max(CounterValue) by Computer
    | where AggregatedValue >=70%


//Disk/File system Utilization Above 60% and below 70%

    Perf
    | where CounterName == "% Used Space"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = avg(CounterValue) by Computer
    | where InstanceName == "/data"
    | where AggregatedValue between ( 60 .. 70 )


//Disk/File system Utilization Above 70% 

    Perf
    | where CounterName == "% Used Space"
    | where TimeGenerated > ago(15min)
    | summarize AggregatedValue = avg(CounterValue) by Computer
    | where InstanceName == "/data"
    | where AggregatedValue >=70


//Min, Avg, Max - Memory Utilization 

    Perf
    | where ObjectName == 'Memory' and CounterName == "% Used Memory"
    | where TimeGenerated > ago(30d)
    | summarize min(CounterValue), avg(CounterValue), max(CounterValue) by Computer

   or 

    Perf 
    | where ObjectName == "Memory"
    | CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use"
    | where TimeGenerated between(datetime(2021-05-01 00:00:00) .. datetime('2021-05-31 00:00:00'))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = min(CounterValue) by Computer, InstanceName
    
<b> VM CPU and Memory Perrformance by VM Details</b>    
    
    Perf
    | where CounterName == "% Processor Time"  and InstanceName == "_Total"
    | where TimeGenerated > ago(30d)
    | project bin(TimeGenerated, 30d), Computer, CPU=(CounterValue), _ResourceId, Type, SourceSystem
    | join (
       Perf
        | where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" 
        | where TimeGenerated > ago(30d)
        | project bin(TimeGenerated, 30d), Computer, MEMORY=CounterValue, _ResourceId, Type, SourceSystem
    ) on TimeGenerated, Computer
    | join ( VMComputer | where AzureLocation != "" | summarize by Computer, AzureImageOffering, AzureLocation, AzureImageSku, OperatingSystemFamily, VirtualMachineNativeName, VirtualMachineType, DisplayName, HostName,  AzureResourceName, AzureSubscriptionId, AzureResourceGroup, OperatingSystemFullName, Cpus ) on Computer
    | summarize MIN_CPU=min(CPU), AVG_CPU=avg(CPU), MAX_CPU=max(CPU), MIN_MEMORY=min(MEMORY), AVG_MEMORY=avg(MEMORY), MAX_MEMORY=max(MEMORY) 
    by Computer, _ResourceId, Type, SourceSystem, AzureImageOffering, AzureLocation, AzureImageSku, OperatingSystemFamily, VirtualMachineNativeName, VirtualMachineType, DisplayName, HostName, AzureResourceName, AzureSubscriptionId, AzureResourceGroup, OperatingSystemFullName, Cpus
    
