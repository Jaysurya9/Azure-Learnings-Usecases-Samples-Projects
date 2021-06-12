<h2>KQL Query - For Scheduling Automated reports of VMs Performance</h2>

      Perf
      | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
      | summarize MIN_CPU = min(CounterValue), AVG_CPU = avg(CounterValue), MAX_CPU = max(CounterValue) by bin(TimeGenerated, 30d), Computer
      | join 
      (
         Perf
          | where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" 
          | summarize AVG_MEM=avg(CounterValue), MIN_MEM=min(CounterValue), MAX_MEM=max(CounterValue) by bin(TimeGenerated, 30d), Computer
      ) on Computer
      | join
      (
      VMComputer 
      | extend AzureSubscriptionId=case(AzureSubscriptionId =~ '','SubName1',AzureSubscriptionId =~ '','SubName2',AzureSubscriptionId =~ '','SubName3',AzureSubscriptionId =~ '','SubName4',AzureSubscriptionId =~ '','QIAGEN ITO Sandbox',AzureSubscriptionId =~ '','SubName5',AzureSubscriptionId)
      | summarize by Computer, AzureImageOffering, AzureLocation, AzureImageSku, 
      OperatingSystemFamily, VirtualMachineNativeName, VirtualMachineType, DisplayName, HostName,  AzureResourceName, AzureSubscriptionId, AzureResourceGroup, OperatingSystemFullName, Cpus, AzureSize, AzureImagePublisher, AzureImageVersion) on Computer
      | project HostName, AzureSubscriptionId, AzureResourceGroup, AzureLocation, Computer, OperatingSystemFamily, OperatingSystemFullName, AzureSize, Cpus, MIN_CPU, AVG_CPU, MAX_CPU
