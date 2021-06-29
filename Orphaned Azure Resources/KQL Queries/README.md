<h1>Orphaned Azure Resources</h1>

<h2>KQL Azure Resource Graph Query – to find Orphaned Disks</h2>

Resources
| where type has "microsoft.compute/disks"
| extend diskState = tostring(properties.diskState)
| where  diskState == 'Unattached' //or managedBy == ""
| where subscriptionId == "" 
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
| extend subscriptionId=case(subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','SubscriptionName2',subscriptionId =~ '','SubscriptionName3',subscriptionId =~ '','SubscriptionName4',subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','',subscriptionId)
| where tags.Environment == "Production"
| project name, diskState, managedBy, subscriptionId, resourceGroup, location, tags


<h2>KQL Azure Resource Graph Query – to find Orphaned NICs</h2>

Resources
| where type has "microsoft.network/networkinterfaces"
| where "{nicWithPrivateEndpoints}" !has id
| where properties !has 'virtualmachine'
| where subscriptionId == "" 
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
| extend subscriptionId=case(subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','SubscriptionName2',subscriptionId =~ '','SubscriptionName3',subscriptionId =~ '','SubscriptionName4',subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','',subscriptionId)
| where tags.Environment == "Production"
| project name, location, tags, subscriptionId, resourceGroup


<h2>KQL Azure Resource Graph Query – to find Orphaned NSGs</h2>

Resources
| where type =~ 'microsoft.network/networksecuritygroups' 
and isnull(properties.networkInterfaces) 
and isnull(properties.subnets)
| where subscriptionId == "" 
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
or subscriptionId == ""
| extend subscriptionId=case(subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','SubscriptionName2',subscriptionId =~ '','SubscriptionName3',subscriptionId =~ '','SubscriptionName4',subscriptionId =~ '','SubscriptionName1',subscriptionId =~ '','',subscriptionId)
| where tags.Environment != ""
| project name, location, tags, resourceGroup, subscriptionId