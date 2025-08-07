# AWS Transfer Family with Azure AD Integration

This project deploys an AWS Transfer Family service with Azure AD (Entra ID) integration for authentication using AWS CloudFormation.

## Prerequisites

- AWS CLI installed and configured
- AWS SSO access with appropriate permissions
- Azure AD application registered with:
  - Client ID
  - Domain name
- Make utility installed
- Active AWS SSO profile

## Project Structure

```
.
├── MakeFile                       # Deployment automation scripts
├── README.md                      # This file
├── setup-aws-networking.yaml      # VPC and networking infrastructure
├── transfer-family-solution.yaml  # Transfer Family service setup
├── parameters.json               # Network stack parameters
└── sftp-parameters.json         # SFTP stack parameters
```

## Available Commands

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

## Deployment Process

1. **Configure Parameters**
   - Update `parameters.json` with your network settings
   - Update `sftp-parameters.json` with your Azure AD settings

2. **Deploy Infrastructure**
   ```bash
   # Login to AWS SSO
   make login

   # Deploy network infrastructure
   make setup

   # Deploy Transfer Family service
   make deploy
   ```

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
    "ParameterKey": "VPCId",
    "ParameterValue": "!ImportValue sftp-networksetup-vpcid"
  },
  {
    "ParameterKey": "AzureClientId",
    "ParameterValue": "<your-azure-client-id>"
  },
  {
    "ParameterKey": "AzureDomain",
    "ParameterValue": "<your-domain>"
  },
  {
    "ParameterKey": "S3BucketName",
    "ParameterValue": "<bucket-name>"
  }
]
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROFILE` | AWS SSO profile name | `glbl-infra-ops-dev` |

## Troubleshooting

1. **Stack Creation Fails**
   - Check CloudFormation console for detailed error messages
   - Verify parameter values in JSON files
   - Ensure AWS SSO session is active

2. **Authentication Issues**
   - Verify Azure AD credentials
   - Check CloudWatch logs for authentication failures
   - Ensure Azure AD app has correct permissions

3. **Network Issues**
   - Confirm VPC and subnet configurations
   - Check security group rules
   - Verify network stack outputs

## Notes

- Stack deployment typically takes 10-15 minutes
- Network stack must be deployed before Transfer Family stack
- Always verify parameters before deployment
- Use AWS CloudWatch for monitoring and troubleshooting

## Security Considerations

- Keep Azure AD credentials secure
- Review and minimize IAM permissions
- Monitor AWS CloudTrail for security events
- Regularly rotate credentials and secrets

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull