### Creating a Service Principal using the Azure CLI

Firstly, login to the Azure CLI using:

```
$ az login
```

Once logged in - it's possible to list the Subscriptions associated with the account via:

```
$ az account list
```

*The output (similar to below) will display one or more Subscriptions - with the id field being the subscription_id field referenced above.*

```
[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000001",
    "isDefault": true,
    "name": "PAYG Subscription",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000123",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
```

Should you have more than one Subscription, you can specify the Subscription to use via the following command:

```
$ az account set --subscription="00000000-0000-0000-0000-000000000001"
```

We can now create the Service Principal which will have permissions to manage resources in the specified Subscription using the following command:

```
$ az ad sp create-for-rbac -n "MyTerraform" --role="Contributor" --scopes="/subscriptions/00000000-0000-0000-0000-000000000001"
```

This command will output 5 values:

```
{
  "appId": "00000000-0000-0000-0000-000000000456",
  "displayName": "MyTerraform",
  "name": "http://MyTerraform",
  "password": "0000-0000-0000-0000-000000000789",
  "tenant": "00000000-0000-0000-0000-000000000123"
}
```

These values map to the Terraform variables like so:

- appId is the client_id defined above.
- password is the client_secret defined above.
- tenant is the tenant_id defined above.
