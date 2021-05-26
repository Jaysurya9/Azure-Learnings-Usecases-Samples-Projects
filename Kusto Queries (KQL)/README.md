Object Name	Counter Name
Logical Disk	% Free Inodes
Logical Disk	% Free Space
Logical Disk	% Used Inodes
Logical Disk	% Used Space
Logical Disk	Disk Read Bytes/sec
Logical Disk	Disk Reads/sec
Logical Disk	Disk Transfers/sec
Logical Disk	Disk Write Bytes/sec
Logical Disk	Disk Writes/sec
Logical Disk	Free Megabytes
Logical Disk	Logical Disk Bytes/sec
Memory	% Available Memory
Memory	% Available Swap Space
Memory	% Used Memory
Memory	% Used Swap Space
Memory	Available MBytes Memory
Memory	Available MBytes Swap
Memory	Page Reads/sec
Memory	Page Writes/sec
Memory	Pages/sec
Memory	Used MBytes Swap Space
Memory	Used Memory MBytes
Network	Total Bytes Transmitted
Network	Total Bytes Received
Network	Total Bytes
Network	Total Packets Transmitted
Network	Total Packets Received
Network	Total Rx Errors
Network	Total Tx Errors
Network	Total Collisions
Physical Disk	Avg. Disk sec/Read
Physical Disk	Avg. Disk sec/Transfer
Physical Disk	Avg. Disk sec/Write
Physical Disk	Physical Disk Bytes/sec
Process	Pct Privileged Time
Process	Pct User Time
Process	Used Memory kBytes
Process	Virtual Shared Memory
Processor	% DPC Time
Processor	% Idle Time
Processor	% Interrupt Time
Processor	% IO Wait Time
Processor	% Nice Time
Processor	% Privileged Time
Processor	% Processor Time
Processor	% User Time
System	Free Physical Memory
System	Free Space in Paging Files
System	Free Virtual Memory
System	Processes
System	Size Stored In Paging Files
System	Uptime
System	Users



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

