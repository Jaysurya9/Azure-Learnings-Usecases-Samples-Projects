# Azure Backup Center

<h2> Report of Backup center | Backup instances </h2>

Information of Azure Backup Instances

<h5>Azure Resource Graph Query for Azure Backup Instances</h5>
<h6>KQL Query</h6>

    RecoveryServicesResources 
    | where type in~ ('Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems')
    |extend policy = properties.policyInfo.policyId
    | extend vaultName = case(type =~ 'microsoft.dataprotection/backupVaults/backupInstances',split(split(id, '/Microsoft.DataProtection/backupVaults/')[1],'/')[0],type =~ 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems',split(split(id, '/Microsoft.RecoveryServices/vaults/')[1],'/')[0],'--')
    | extend dataSourceType = case(type =~ 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems',strcat(properties.backupManagementType,'/',properties.workloadType),type =~ 'microsoft.dataprotection/backupVaults/backupInstances',properties.dataSourceInfo.datasourceType,'--')
    | extend friendlyName = properties.friendlyName
    | extend dsResourceGroup = split(split(properties.dataSourceInfo.resourceID, '/resourceGroups/')[1],'/')[0]
    | extend dsSubscription = split(split(properties.dataSourceInfo.resourceID, '/subscriptions/')[1],'/')[0]
    | extend lastRestorePoint = properties.lastRecoveryPoint
    | extend primaryLocation = properties.dataSourceInfo.resourceLocation
    | extend policyName = case(type =~ 'microsoft.dataprotection/backupVaults/backupInstances', extract(@'([^/]*)/backupPolicies/([^/]*)', 2, tostring(policy)),type =~ 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems', properties.policyInfo.name,'--')
    | extend protectionState = properties.currentProtectionState
    | project id, name,type, resourceGroup, vaultName, friendlyName, subscriptionId, dataSourceType, protectionState, policyName, primaryLocation, lastRestorePoint, properties, dsResourceGroup, dsSubscription, location
    | where (protectionState in~ ('ConfiguringProtection','ProtectionConfigured','ConfiguringProtectionFailed','ProtectionStopped','SoftDeleted','ProtectionError')) and (dataSourceType in~ ('AzureIaasVM/VM')) and (dsSubscription in~ ('68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43','68xxx777-xxxx-xxxx-xxxx-167xx3c2xx43'))

<h2> Report of Backup center | Vaults </h2>

Information of Recovery Services vaults and Backup

<h5>Azure Resource Graph Query for Recovery Services vaults and Backup</h5>
<h6>KQL Query</h6>

    Resources
    | where type in~ ('microsoft.recoveryservices/vaults','Microsoft.DataProtection/BackupVaults')
    | project name,resourceGroup,location,type,id
    | where (type in~ ('microsoft.recoveryservices/vaults','Microsoft.DataProtection/BackupVaults'))
    
<h2> Report of Backup center | Backup policies</h2>

Information of Azure Backup policies

<h5>Azure Resource Graph Query for Azure Backup policies</h5>
<h6>KQL Query</h6>    
    
    
    RecoveryServicesResources 
    | where type in~ ('Microsoft.RecoveryServices/vaults/backupPolicies')
    | extend vaultName = case(type =~ 'microsoft.dataprotection/backupVaults/backupPolicies', split(split(id, '/Microsoft.DataProtection/backupVaults/')[1],'/')[0],type =~ 'microsoft.recoveryservices/vaults/backupPolicies', extract(@'([^/]*.[^/]*)/[V|v]aults/([^/]*)', 2, id),'--')
    | extend workloadType = tostring(case (isnotnull(properties.workLoadType), properties.workLoadType, properties.backupManagementType == 'AzureIaasVM', 'VM', properties.backupManagementType == 'AzureStorage', 'AzureFileShare','--'))
    | extend vaultType = case(type =~ 'microsoft.dataprotection/backupVaults/backupPolicies', 'Backup vault',type =~ 'microsoft.recoveryservices/vaults/backupPolicies', 'Recovery Services vault','--')
    | extend datasourceType = case(type =~ 'Microsoft.RecoveryServices/vaults/backupPolicies', strcat(properties.backupManagementType,'/', workloadType),type =~ 'microsoft.dataprotection/backupVaults/backupPolicies',properties.datasourceTypes[0],'--')
    | project id,name,vaultName,resourceGroup,properties,datasourceType,vaultType
    | where (datasourceType in~ ('AzureIaasVM/VM'))
