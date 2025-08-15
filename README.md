# AWS Transfer Family with Azure AD (Entra ID) Integration

This project deploys an AWS Transfer Family service with Azure AD (Entra ID) integration for authentication using AWS CloudFormation and API Gateway as a custom identity provider.

---

## Prerequisites

- AWS CLI installed and configured
- AWS SSO access with appropriate permissions
- Azure AD application registered with:
  - Client ID
  - Domain name
  - Tenant ID
- Make utility installed
- Active AWS SSO profile

---

## Project Structure

```
.
├── Makefile                       # Deployment automation scripts
├── README.md                      # This file
├── setup-aws-networking.yaml      # VPC and networking infrastructure
├── transfer-family-solution.yaml  # Transfer Family service setup
├── parameters.json                # Network stack parameters
├── sftp-parameters.json           # SFTP stack parameters
```

---

## Deployment Overview

This solution creates:

- A VPC and networking stack for Transfer Family
- An S3 bucket for user data
- IAM roles and policies for Transfer Family and Lambda
- DynamoDB table for group access mapping
- API Gateway endpoint for custom authentication
- Lambda function for Azure AD authentication and user config
- AWS Transfer Family server with API Gateway as the identity provider

---

## API Gateway Identity Provider Path

**Important:**  
The Transfer Family server is configured to use API Gateway with the following identity provider URL:

```
https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/servers/{serverId}/users/{username}/config
```

- The API Gateway resources must match this path exactly.
- This enables protocol and sourceIp to be passed to the Lambda function for advanced authentication scenarios.

---

## Available Makefile Commands

All commands support the `PROFILE` parameter to specify your AWS SSO profile:

```bash
make <command> PROFILE=your-profile-name
```

### Core Commands

1. **Login to AWS SSO**
   ```bash
   make login
   ```

2. **Deploy Network Infrastructure**
   ```bash
   make setup
   ```

3. **Deploy Transfer Family Service**
   ```bash
   make deploy
   ```

### Cleanup Commands

1. **Remove Transfer Family Stack**
   ```bash
   make destroy
   ```

2. **Remove Network Stack**
   ```bash
   make destroy-setup
   ```

---

## Configuration Files

### Network Parameters (`parameters.json`)
```json
[
  {
    "ParameterKey": "VpcName",
    "ParameterValue": "<your-vpc-name>"
  },
  // ... other network parameters
]
```

### SFTP Parameters (`sftp-parameters.json`)
```json
[
  {
    "ParameterKey": "CreateServer",
    "ParameterValue": "true"
  },
  {
    "ParameterKey": "SecretsManagerRegion",
    "ParameterValue": "eu-central-1"
  },
  {
    "ParameterKey": "AzureADClientID",
    "ParameterValue": "<your-azure-client-id>"
  },
  {
    "ParameterKey": "AzureADDomain",
    "ParameterValue": "<your-azure-domain>"
  },
  {
    "ParameterKey": "AzureADTenantID",
    "ParameterValue": "<your-azure-tenant-id>"
  }
]
```

---

## Deployment Steps

1. **Configure Parameters**
   - Update `parameters.json` for your network stack
   - Update `sftp-parameters.json` for your Transfer Family stack

2. **Deploy Infrastructure**
   ```bash
   make login
   make setup
   make deploy
   ```

3. **Verify API Gateway Path**
   - Ensure the resource path `/servers/{serverId}/users/{username}/config` exists in API Gateway.
   - The Transfer Family server must use this path in its `IdentityProviderDetails.Url`.

---

## Troubleshooting

1. **Stack Creation Fails**
   - Check CloudFormation console for detailed error messages
   - Verify parameter values in JSON files
   - Ensure AWS SSO session is active

2. **Authentication Issues**
   - Verify Azure AD credentials
   - Check CloudWatch logs for authentication failures
   - Ensure Azure AD app has correct permissions

3. **API Gateway/Transfer Family Integration**
   - Ensure the API Gateway resource path matches the Transfer Family IdentityProviderDetails URL
   - The URL must be HTTPS and include `/servers/{serverId}/users/{username}/config`
   - Redeploy API Gateway after changes

4. **Network Issues**
   - Confirm VPC and subnet configurations
   - Check security group rules
   - Verify network stack outputs

---

## Security Considerations

- Keep Azure AD credentials secure
- Review and minimize IAM permissions
- Monitor AWS CloudTrail for security events
- Regularly rotate credentials and secrets

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request