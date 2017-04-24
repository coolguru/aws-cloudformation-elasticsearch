

## Description


## Hierarchy



## Required variables with no default

### `DOMAIN_NAME`:
  * description: A name for the Amazon ES domain.


## Required variables with default

### `STACK_NAME`:
  * description: SQS Cloudformation stack name
  * default: sqs-stack


## Optional variables with default

### `ON_FAILURE`:
  * description: Action to be taken if stack creation fails. This must be one of: DO_NOTHING, ROLLBACK, or DELETE. Conflicts with disable_rollback.
  * default: ROLLBACK

### `TIMEOUT_IN_MINUTES`:
  * description: The amount of time that can pass before the stack status becomes CREATE_FAILED.
  * default: 60

### `CAPABILTIES`:
  * description: A list of capabilities. Currently, the only valid value is CAPABILITY_IAM.
  * default: CAPABILITY_IAM


## Optional variables with no default

### `DEDICATED_MASTER_INSTANCE_COUNT`:
  * description: Dedicated master instance count.

### `DEDICATED_MASTER_INSTANCE_TYPE`:
  * description: Dedicated master instance type.

### `MASTER_INSTANCE_COUNT`:
  * description: Instance count.

### `MASTER_INSTANCE_TYPE`:
  * description: Instance type.

### `EBS_VOLUME_SIZE`:
  * description: EBS volume size.

### `EBS_VOLUME_IOPS`:
  * description: EBS volume iops.

### `SNAPSHOT_START_HOUR`:
  * description: Snapshot start hour.

### `DISABLE_ROLLBACK`:
  * description: Set to true to disable rollback of the stack if stack creation failed.

### `NOTIFICATION_ARNS`:
  * description: The Simple Notification Service (SNS) topic ARNs to publish stack related events.

### `POLICY_URL`:
  * description: Location of a file containing the stack policy. Conflicts w/ POLICY_BODY.

### `POLICY_BODY`:
  * description: Structure containing the stack policy body. Conflicts w/ POLICY_URL.

### `ROLE_ARN`:
  * description: The Amazon Resource Name (ARN) of an AWS Identity and Access Management (IAM) role that AWS CloudFormation assumes to update the stack.

### `STACK_TAGS`:
  * description: tags to apply to the stack

## Tags


## Categories


## Diagram


## Icon


