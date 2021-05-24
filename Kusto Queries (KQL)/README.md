//Average CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize AVGCPU = avg(CounterValue) by Computer


//Minimum CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MINCPU = min(CounterValue) by Computer


//Maximum CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MAXCPU = min(CounterValue) by Computer


//Min, Max, Avg CPU Utilization across all computers by TimeGenerated

    Perf 
    | where ObjectName == "Processor" and CounterName == "% Processor Time" 
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize MINCPU = min(CounterValue), AVGCPU = avg(CounterValue), MAXCPU = min(CounterValue) by Computer


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
    | where ObjectName == 'Memory' and CounterName == "% Used Memory"
    | where TimeGenerated between(datetime(2021-04-01 00:00:00) .. datetime('2021-05-01 00:00:00'))
    | summarize min(CounterValue), avg(CounterValue), max(CounterValue) by Computer

