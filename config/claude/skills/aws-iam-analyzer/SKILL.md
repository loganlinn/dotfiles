---
name: aws-iam-policy-analyst
description: Expert analysis and generation of AWS IAM policies using authoritative data from the AWS IAM DuckDB database. Use this skill for any IAM-related questions, policy generation, permission analysis, or resource authorization queries. ALWAYS query the database rather than relying on pre-existing knowledge about AWS IAM actions, conditions, or resource types.
license: MIT
---

# AWS IAM Policy Analyst

## Overview

This skill enables thorough, evidence-based analysis and generation of AWS IAM policies using the authoritative AWS IAM data compiled from official AWS documentation. The data is stored in a DuckDB database and contains comprehensive information about all AWS services, actions, resource types, condition keys, and their relationships.

**Core Principle:** NEVER rely on pre-training knowledge about IAM actions, conditions, or resource types. ALWAYS query the database to provide accurate, up-to-date information.

---

# Database Access

## Connecting to the Database

Use DuckDB CLI to access the remote read-only database:

```bash
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
-- Your queries here
"
```

**Note:** Do not use the `-readonly` flag when using an in-memory database with ATTACH. The attached database is already read-only.

**Local Access (if database exists locally):**

```bash
duckdb /path/to/github.com/tobilg/aws-iam-data/data/db/iam.duckdb -readonly -c "SELECT * FROM services LIMIT 5;"
```

## Database Schema

The database consists of 8 interconnected tables:

### Core Tables

**`services`** - AWS services

- `service_id` (INTEGER, PK) - Unique service identifier
- `name` (VARCHAR) - Full service name (e.g., "Amazon RDS")
- `prefix` (VARCHAR) - Service prefix used in actions (e.g., "rds")
- `reference_url` (VARCHAR) - AWS documentation URL

**`actions`** - IAM actions

- `action_id` (INTEGER, PK) - Unique action identifier
- `service_id` (INTEGER, FK) - Parent service
- `name` (VARCHAR) - Full action name INCLUDING prefix (e.g., "rds:DeleteDBInstance")
- `reference_url` (VARCHAR) - API documentation URL
- `permission_only_flag` (BOOLEAN) - Whether action is permission-only
- `access_level` (VARCHAR) - Access level: Read, Write, List, Tagging, Permissions management

**`resource_types`** - Resource types that actions can operate on

- `resource_type_id` (INTEGER, PK) - Unique resource type identifier
- `service_id` (INTEGER, FK) - Parent service
- `name` (VARCHAR) - Resource type name (e.g., "db", "cluster")
- `reference_url` (VARCHAR) - Documentation URL
- `arn_pattern` (VARCHAR) - ARN pattern with variables (e.g., "arn:${Partition}:rds:${Region}:${Account}:db:${DbInstanceName}")

**`condition_keys`** - IAM condition keys

- `condition_key_id` (INTEGER, PK) - Unique condition key identifier
- `name` (VARCHAR) - Full condition key name (e.g., "rds:DatabaseEngine", "aws:ResourceTag/${TagKey}")
- `reference_url` (VARCHAR) - Documentation URL
- `description` (VARCHAR) - Human-readable description
- `type` (VARCHAR) - Data type: String, Bool, Numeric, Date, etc.

### Relationship Tables

**`actions_resource_types`** - Which resources each action can operate on

- `action_resource_type_id` (BIGINT, PK)
- `action_id` (INTEGER, FK)
- `resource_type_id` (INTEGER, FK)
- `required_flag` (BOOLEAN) - Whether the resource type is required for this action

**`actions_condition_keys`** - Condition keys available for action+resource combinations

- `action_condition_key_id` (BIGINT, PK)
- `action_resource_type_id` (BIGINT, FK) - References specific action+resource combination
- `action_id` (INTEGER, FK)
- `condition_key_id` (INTEGER, FK)

**`resource_types_condition_keys`** - Condition keys available at the resource type level

- `resource_type_condition_key_id` (BIGINT, PK)
- `resource_type_id` (BIGINT, FK)
- `condition_key_id` (INTEGER, FK)

**`actions_dependant_actions`** - Actions that depend on other actions

- `action_dependent_action_id` (INTEGER, PK)
- `action_resource_type_id` (BIGINT, FK)
- `action_id` (INTEGER, FK) - The primary action
- `dependent_action_id` (INTEGER, FK) - Action that must also be allowed

---

# Core Principles

## 1. Evidence-Based Analysis

**ALWAYS query the database before making statements about:**

- Whether an action exists
- What resources an action operates on
- What conditions are supported
- Action access levels
- ARN patterns
- Dependent actions

**Show your work:**

- Include the SQL queries you used
- Display query results
- Cite reference URLs from the database

## 2. Accurate Action Names

**CRITICAL:** Action names in the `actions` table include the service prefix.

✅ Correct: `rds:DeleteDBInstance`
❌ Wrong: `DeleteDBInstance`

When querying actions, use the full name with prefix:

```sql
WHERE a.name = 'rds:DeleteDBInstance'  -- Correct
```

## 3. Understanding Condition Key Relationships

**Two levels of condition keys:**

1. **Resource-Type Level** (`resource_types_condition_keys`)
   - Conditions applicable to a resource type across all actions
   - More commonly populated in AWS documentation
   - Query: Join `resource_types` → `resource_types_condition_keys` → `condition_keys`

2. **Action-Resource Level** (`actions_condition_keys`)
   - Conditions specific to an action+resource combination
   - Less commonly used (often empty)
   - Query: Join `actions_resource_types` → `actions_condition_keys` → `condition_keys`

**Always check resource-type level conditions** when action-level conditions are empty.

## 4. Required vs Optional Resources

Actions can operate on multiple resource types with different requirements:

- `required_flag = true`: Resource MUST be specified in policy
- `required_flag = false`: Resource is optional (can use "\*")

Query the `actions_resource_types` table to determine requirements.

## 5. ARN Pattern Matching

ARN patterns use variables in `${VarName}` format:

- `${Partition}`: Usually "aws"
- `${Region}`: AWS region (e.g., "us-east-1") or "\*"
- `${Account}`: AWS account ID or "\*"
- Resource-specific variables (e.g., `${DbInstanceName}`, `${BucketName}`)

To match an ARN to a resource type, parse the ARN and match against the pattern.

---

# Common Query Patterns

## Pattern 1: Find Actions for a Resource ARN

Given an ARN, find what actions can be performed on it:

```sql
-- Step 1: Identify the service and resource type from ARN
-- Example ARN: arn:aws:rds:us-east-2:123456789012:db:my-database

-- Step 2: Find matching resource type
SELECT
    s.prefix,
    rt.name as resource_type,
    rt.arn_pattern
FROM services s
JOIN resource_types rt ON s.service_id = rt.service_id
WHERE s.prefix = 'rds'
  AND rt.arn_pattern LIKE '%:db:%';

-- Step 3: Find all actions for this resource type
SELECT
    a.name as action,
    a.access_level,
    art.required_flag,
    a.reference_url
FROM actions a
JOIN actions_resource_types art ON a.action_id = art.action_id
JOIN resource_types rt ON art.resource_type_id = rt.resource_type_id
WHERE rt.name = 'db'
  AND rt.service_id = (SELECT service_id FROM services WHERE prefix = 'rds')
ORDER BY a.access_level, a.name;
```

## Pattern 2: Find Conditions for an Action

Get all applicable condition keys for an action:

```sql
-- Find conditions for rds:DeleteDBInstance on db resource
WITH action_info AS (
    SELECT a.action_id, art.action_resource_type_id, art.resource_type_id
    FROM actions a
    JOIN actions_resource_types art ON a.action_id = art.action_id
    JOIN resource_types rt ON art.resource_type_id = rt.resource_type_id
    JOIN services s ON a.service_id = s.service_id
    WHERE s.prefix = 'rds'
      AND a.name = 'rds:DeleteDBInstance'
      AND rt.name = 'db'
)
-- Check action-level conditions first
SELECT
    'action-level' as level,
    ck.name as condition_key,
    ck.type,
    ck.description
FROM action_info ai
JOIN actions_condition_keys ack ON ai.action_resource_type_id = ack.action_resource_type_id
JOIN condition_keys ck ON ack.condition_key_id = ck.condition_key_id

UNION ALL

-- Then resource-type level conditions
SELECT
    'resource-type-level' as level,
    ck.name,
    ck.type,
    ck.description
FROM action_info ai
JOIN resource_types_condition_keys rtck ON ai.resource_type_id = rtck.resource_type_id
JOIN condition_keys ck ON rtck.condition_key_id = ck.condition_key_id
ORDER BY level, condition_key;
```

## Pattern 3: Find Dependent Actions

Some actions require other actions to be granted:

```sql
SELECT
    a1.name as primary_action,
    a2.name as dependent_action,
    a2.access_level as dependent_access_level
FROM actions_dependant_actions ada
JOIN actions a1 ON ada.action_id = a1.action_id
JOIN actions a2 ON ada.dependent_action_id = a2.action_id
WHERE a1.name = 'rds:DeleteDBInstance';
```

## Pattern 4: Generate Least-Privilege Policy

Find minimum required actions for a specific task:

```sql
-- Find Read-level actions for S3 bucket
SELECT
    a.name,
    a.access_level,
    rt.name as resource_type,
    art.required_flag,
    rt.arn_pattern
FROM actions a
JOIN actions_resource_types art ON a.action_id = art.action_id
JOIN resource_types rt ON art.resource_type_id = rt.resource_type_id
JOIN services s ON a.service_id = s.service_id
WHERE s.prefix = 's3'
  AND a.access_level = 'Read'
  AND rt.name = 'bucket'
ORDER BY a.name;
```

## Pattern 5: Search Actions by Pattern

Find actions matching a description or pattern:

```sql
-- Find all delete/remove/destroy actions for a service
SELECT a.name, a.access_level, a.reference_url
FROM actions a
JOIN services s ON a.service_id = s.service_id
WHERE s.prefix = 'rds'
  AND (a.name ILIKE '%delete%'
       OR a.name ILIKE '%remove%'
       OR a.name ILIKE '%destroy%')
ORDER BY a.name;
```

## Pattern 6: Explore Service Capabilities

Get overview of a service:

```sql
-- Service summary
SELECT
    s.name as service,
    s.prefix,
    COUNT(DISTINCT a.action_id) as action_count,
    COUNT(DISTINCT rt.resource_type_id) as resource_type_count,
    COUNT(DISTINCT ck.condition_key_id) as condition_key_count
FROM services s
LEFT JOIN actions a ON s.service_id = a.service_id
LEFT JOIN resource_types rt ON s.service_id = rt.service_id
LEFT JOIN condition_keys ck ON s.service_id = ck.service_id
WHERE s.prefix = 'rds'
GROUP BY s.name, s.prefix;
```

## Pattern 7: Find Actions by Access Level

Useful for creating policies with specific permission boundaries:

```sql
-- Find all Write actions for EC2
SELECT a.name, a.reference_url
FROM actions a
JOIN services s ON a.service_id = s.service_id
WHERE s.prefix = 'ec2'
  AND a.access_level = 'Write'
ORDER BY a.name
LIMIT 20;
```

---

# Context Management Best Practices

## Always Use LIMIT When Exploring

Large services (EC2, IAM) have hundreds of actions. Always limit results:

```sql
-- Good: Limited exploration
SELECT * FROM actions WHERE service_id = 1 LIMIT 10;

-- Bad: Could return 500+ rows
SELECT * FROM actions WHERE service_id = 1;
```

## Count Before Fetching

Check result size before full query:

```sql
-- Step 1: Count results
SELECT COUNT(*) FROM actions WHERE service_id = 1;

-- Step 2: If count is reasonable, fetch with LIMIT
SELECT * FROM actions WHERE service_id = 1 LIMIT 50;
```

## Use CTEs for Complex Queries

Common Table Expressions make queries readable and maintainable:

```sql
WITH ec2_service AS (
    SELECT service_id FROM services WHERE prefix = 'ec2'
),
instance_resource AS (
    SELECT resource_type_id
    FROM resource_types
    WHERE service_id = (SELECT service_id FROM ec2_service)
      AND name = 'instance'
)
SELECT a.name
FROM actions a
JOIN actions_resource_types art ON a.action_id = art.action_id
WHERE art.resource_type_id = (SELECT resource_type_id FROM instance_resource)
LIMIT 20;
```

## Save Intermediate Results

For multi-step analysis, create temp tables:

```sql
-- Create temp table for working set
CREATE TEMP TABLE my_actions AS
SELECT a.action_id, a.name, a.access_level
FROM actions a
JOIN services s ON a.service_id = s.service_id
WHERE s.prefix = 'rds';

-- Query temp table multiple times
SELECT COUNT(*) FROM my_actions WHERE access_level = 'Write';
SELECT name FROM my_actions WHERE access_level = 'Read' LIMIT 10;
```

## Select Only Needed Columns

Reduce context usage by selecting specific columns:

```sql
-- Good: Select what you need
SELECT name, access_level FROM actions LIMIT 10;

-- Wasteful: Select everything
SELECT * FROM actions LIMIT 10;
```

---

# DuckDB-Specific Features

## Remote Database Access

No need for local file - attach remote database:

```sql
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
SELECT * FROM aws_iam.services LIMIT 5;
```

## Export Query Results

Export to various formats for further analysis:

```bash
# Export to CSV
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
COPY (SELECT * FROM aws_iam.actions WHERE service_id = 1)
TO 'ec2_actions.csv' (HEADER, DELIMITER ',');
"

# Export to JSON
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
COPY (SELECT * FROM aws_iam.services)
TO 'services.json';
"

# Export to Parquet
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
COPY (SELECT * FROM aws_iam.condition_keys)
TO 'conditions.parquet';
"
```

## Join with External Data

Join database with AWS CLI outputs or CSV files:

```bash
# Get current IAM policies and join with database
aws iam list-policies --scope Local --output json > my_policies.json

duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Read JSON and join with database
SELECT
    p.PolicyName,
    a.name as matching_action,
    a.access_level
FROM read_json('my_policies.json',
               auto_detect=true,
               format='array') p
JOIN aws_iam.actions a ON a.name LIKE p.PolicyName || '%'
LIMIT 10;
"
```

## Read from Stdin

Pipe AWS CLI output directly:

```bash
aws iam get-policy-version \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess \
    --version-id v1 \
    --query 'PolicyVersion.Document.Statement[0].Action' \
    --output json | \
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
SELECT * FROM read_json('/dev/stdin') AS actions;
"
```

## Full-Text Search

Use pattern matching for exploratory queries:

```sql
-- Find all actions related to encryption
SELECT name, access_level
FROM actions
WHERE name ILIKE '%encrypt%'
   OR name ILIKE '%decrypt%'
   OR name ILIKE '%kms%'
LIMIT 20;
```

## Regex Support

Use regex for complex pattern matching:

```sql
-- Find actions that start with Create, Put, or Add
SELECT name
FROM actions
WHERE regexp_matches(name, '^[a-z]+:(Create|Put|Add)')
LIMIT 20;
```

---

# Common Tasks

## Task 1: Analyze Existing IAM Policy

When user provides an IAM policy, validate it against the database:

```bash
# Steps:
# 1. Extract actions from the policy
# 2. Query database for each action
# 3. Verify resources match ARN patterns
# 4. Check if conditions are valid
# 5. Identify any dependent actions needed

duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Check if action exists
SELECT a.name, a.access_level, a.reference_url
FROM aws_iam.actions a
WHERE a.name IN ('s3:GetObject', 's3:PutObject');
"
```

## Task 2: Generate Least-Privilege Policy

Create minimum permissions for a specific use case:

```bash
# Example: Policy for reading S3 objects

# 1. Find required actions
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

SELECT
    a.name,
    rt.name as resource,
    rt.arn_pattern,
    art.required_flag
FROM aws_iam.actions a
JOIN aws_iam.actions_resource_types art ON a.action_id = art.action_id
JOIN aws_iam.resource_types rt ON art.resource_type_id = rt.resource_type_id
WHERE a.name = 's3:GetObject';
"

# 2. Find dependent actions
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

SELECT a2.name as dependent_action
FROM aws_iam.actions a1
JOIN aws_iam.actions_dependant_actions ada ON a1.action_id = ada.action_id
JOIN aws_iam.actions a2 ON ada.dependent_action_id = a2.action_id
WHERE a1.name = 's3:GetObject';
"

# 3. Generate policy JSON with findings
```

## Task 3: Compare Service Capabilities

Compare IAM capabilities across services:

```bash
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

SELECT
    s.prefix,
    s.name,
    COUNT(DISTINCT a.action_id) as actions,
    COUNT(DISTINCT rt.resource_type_id) as resources,
    COUNT(DISTINCT CASE WHEN a.access_level = 'Write' THEN a.action_id END) as write_actions
FROM aws_iam.services s
LEFT JOIN aws_iam.actions a ON s.service_id = a.service_id
LEFT JOIN aws_iam.resource_types rt ON s.service_id = rt.service_id
WHERE s.prefix IN ('s3', 'rds', 'ec2', 'lambda')
GROUP BY s.prefix, s.name
ORDER BY actions DESC;
"
```

## Task 4: Resource Type Discovery

Find all resources for a service and their ARN patterns:

```bash
duckdb -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

SELECT
    rt.name as resource_type,
    rt.arn_pattern,
    COUNT(DISTINCT art.action_id) as action_count,
    rt.reference_url
FROM aws_iam.resource_types rt
JOIN aws_iam.services s ON rt.service_id = s.service_id
LEFT JOIN aws_iam.actions_resource_types art ON rt.resource_type_id = art.resource_type_id
WHERE s.prefix = 'rds'
GROUP BY rt.name, rt.arn_pattern, rt.reference_url
ORDER BY action_count DESC;
"
```

## Task 5: Condition Key Analysis

Find all available conditions for a use case:

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Find tag-based conditions for S3
SELECT
    ck.name,
    ck.type,
    ck.description,
    COUNT(DISTINCT rt.resource_type_id) as applicable_resources
FROM aws_iam.condition_keys ck
JOIN aws_iam.resource_types_condition_keys rtck ON ck.condition_key_id = rtck.condition_key_id
JOIN aws_iam.resource_types rt ON rtck.resource_type_id = rt.resource_type_id
JOIN aws_iam.services s ON rt.service_id = s.service_id
WHERE s.prefix = 's3'
  AND ck.name LIKE '%tag%'
GROUP BY ck.name, ck.type, ck.description
ORDER BY ck.name;
"
```

## Task 6: Security Audit

Identify high-risk actions in a service:

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Find all Permissions management and Write actions for IAM
SELECT
    a.name,
    a.access_level,
    a.reference_url
FROM aws_iam.actions a
JOIN aws_iam.services s ON a.service_id = s.service_id
WHERE s.prefix = 'iam'
  AND a.access_level IN ('Permissions management', 'Write')
ORDER BY a.access_level, a.name;
"
```

---

# Pitfalls to Avoid

## ❌ Pitfall 1: Hallucinating IAM Information

**Wrong approach:**

```
"The rds:DeleteDBInstance action supports the rds:MultiAz condition..."
```

**Correct approach:**

```bash
# First query the database
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);
SELECT ck.name FROM aws_iam.condition_keys ck
JOIN aws_iam.resource_types_condition_keys rtck ON ck.condition_key_id = rtck.condition_key_id
JOIN aws_iam.resource_types rt ON rtck.resource_type_id = rt.resource_type_id
WHERE rt.name = 'db' AND ck.name LIKE '%MultiAz%';
"

# Then state: "According to the database, the db resource type supports..."
```

## ❌ Pitfall 2: Wrong Action Name Format

**Wrong:**

```sql
WHERE a.name = 'DeleteDBInstance'  -- Missing prefix
```

**Correct:**

```sql
WHERE a.name = 'rds:DeleteDBInstance'  -- Includes prefix
```

## ❌ Pitfall 3: Ignoring Resource-Type Conditions

**Wrong:**

```sql
-- Only checking action-level conditions
SELECT ck.name FROM actions_condition_keys ack
JOIN condition_keys ck ON ack.condition_key_id = ck.condition_key_id
WHERE ack.action_id = 123;
-- Result: Empty (most actions don't have action-level conditions)
```

**Correct:**

```sql
-- Check resource-type level conditions
SELECT ck.name FROM resource_types_condition_keys rtck
JOIN condition_keys ck ON rtck.condition_key_id = ck.condition_key_id
WHERE rtck.resource_type_id = 45;
-- Result: All applicable conditions
```

## ❌ Pitfall 4: Loading Entire Tables

**Wrong:**

```sql
SELECT * FROM actions;  -- Could return 10,000+ rows
```

**Correct:**

```sql
SELECT COUNT(*) FROM actions;  -- Check size first
SELECT * FROM actions LIMIT 50;  -- Then limit results
```

## ❌ Pitfall 5: Not Checking Required vs Optional

**Wrong:**

```json
{
  "Action": "s3:ListBucket",
  "Resource": "arn:aws:s3:::my-bucket/*" // Wrong resource type
}
```

**Correct:** Query first

```sql
SELECT rt.name, rt.arn_pattern, art.required_flag
FROM actions_resource_types art
JOIN resource_types rt ON art.resource_type_id = rt.resource_type_id
JOIN actions a ON art.action_id = a.action_id
WHERE a.name = 's3:ListBucket';
-- Shows: bucket (not object), required
```

## ❌ Pitfall 6: Ignoring Dependent Actions

**Wrong:** Grant only the requested action

```json
{
  "Action": "ec2:RunInstances",
  "Resource": "*"
}
```

**Correct:** Check for dependent actions first

```sql
SELECT a2.name FROM actions_dependant_actions ada
JOIN actions a1 ON ada.action_id = a1.action_id
JOIN actions a2 ON ada.dependent_action_id = a2.action_id
WHERE a1.name = 'ec2:RunInstances';
-- May show additional required actions
```

## ❌ Pitfall 7: Incorrect ARN Pattern Matching

**Wrong:** Assume ARN structure

```
arn:aws:rds:us-east-1:123456789012:database:my-db  // Wrong!
```

**Correct:** Query the pattern

```sql
SELECT arn_pattern FROM resource_types
WHERE name = 'db' AND service_id = (SELECT service_id FROM services WHERE prefix = 'rds');
-- Result: arn:${Partition}:rds:${Region}:${Account}:db:${DbInstanceName}
```

---

# Workflow Example

## Complete Analysis: "What permissions do I need to delete an RDS database?"

### Step 1: Identify the Resource Type

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Find RDS resource types
SELECT name, arn_pattern
FROM aws_iam.resource_types
WHERE service_id = (SELECT service_id FROM aws_iam.services WHERE prefix = 'rds')
  AND name = 'db';
"
```

**Output:**

```
name | arn_pattern
-----+--------------------------------------------------------
db   | arn:${Partition}:rds:${Region}:${Account}:db:${DbInstanceName}
```

### Step 2: Find Delete Actions

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Find delete actions for db resource
SELECT
    a.name,
    a.access_level,
    art.required_flag,
    a.reference_url
FROM aws_iam.actions a
JOIN aws_iam.actions_resource_types art ON a.action_id = art.action_id
JOIN aws_iam.resource_types rt ON art.resource_type_id = rt.resource_type_id
WHERE rt.name = 'db'
  AND a.name LIKE '%Delete%'
ORDER BY a.name;
"
```

**Output:**

```
name                      | access_level | required_flag | reference_url
--------------------------+--------------+---------------+------------------
rds:DeleteDBInstance      | Write        | true          | https://...
```

### Step 3: Find Dependent Actions

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Check for dependent actions
SELECT a2.name as dependent_action
FROM aws_iam.actions a1
JOIN aws_iam.actions_dependant_actions ada ON a1.action_id = ada.action_id
JOIN aws_iam.actions a2 ON ada.dependent_action_id = a2.action_id
WHERE a1.name = 'rds:DeleteDBInstance';
"
```

### Step 4: Find Applicable Conditions

```bash
duckdb -readonly -c "
ATTACH 'https://raw.githubusercontent.com/tobilg/aws-iam-data/main/data/db/iam.duckdb' as aws_iam (READ_ONLY);

-- Find conditions for db resource type
SELECT
    ck.name,
    ck.type,
    ck.description
FROM aws_iam.condition_keys ck
JOIN aws_iam.resource_types_condition_keys rtck ON ck.condition_key_id = rtck.condition_key_id
JOIN aws_iam.resource_types rt ON rtck.resource_type_id = rt.resource_type_id
WHERE rt.name = 'db'
  AND rt.service_id = (SELECT service_id FROM aws_iam.services WHERE prefix = 'rds')
ORDER BY ck.name;
"
```

**Output:**

```
name                          | type    | description
------------------------------+---------+----------------------------------------
aws:ResourceTag/${TagKey}     | String  | Filters access based on tag key-value pairs
rds:DatabaseClass             | String  | Filters access by DB instance class
rds:DatabaseEngine            | String  | Filters access by database engine
...
```

### Step 5: Generate Policy

Based on database queries, generate the IAM policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DeleteRDSDatabase",
      "Effect": "Allow",
      "Action": ["rds:DeleteDBInstance"],
      "Resource": "arn:aws:rds:us-east-2:123456789012:db:my-database"
    }
  ]
}
```

### Step 6: Add Conditions (Optional)

Add restrictions based on available condition keys:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DeleteRDSDatabaseWithConditions",
      "Effect": "Allow",
      "Action": ["rds:DeleteDBInstance"],
      "Resource": "arn:aws:rds:*:123456789012:db:*",
      "Condition": {
        "StringEquals": {
          "rds:DatabaseEngine": "postgres",
          "aws:ResourceTag/Environment": "development"
        }
      }
    }
  ]
}
```

---

# Best Practices Summary

1. **Always Query First** - Never rely on pre-training knowledge about IAM
2. **Use Correct Action Names** - Include service prefix (e.g., `rds:DeleteDBInstance`)
3. **Check Resource-Type Conditions** - Most conditions are at resource-type level
4. **Verify Required Resources** - Check `required_flag` in `actions_resource_types`
5. **Find Dependent Actions** - Query `actions_dependant_actions` table
6. **Limit Query Results** - Always use `LIMIT` when exploring
7. **Show Evidence** - Include SQL queries and results in your analysis
8. **Export for Large Results** - Use COPY TO for datasets that exceed context limits
9. **Use CTEs for Clarity** - Make complex queries readable
10. **Cite References** - Include `reference_url` from database in your answers

---

# Quick Reference

## Essential Queries

**List all services:**

```sql
SELECT prefix, name FROM services ORDER BY prefix LIMIT 50;
```

**Count actions in a service:**

```sql
SELECT COUNT(*) FROM actions
WHERE service_id = (SELECT service_id FROM services WHERE prefix = 'rds');
```

**Find action by name:**

```sql
SELECT * FROM actions WHERE name = 'rds:DeleteDBInstance';
```

**Get resource types for service:**

```sql
SELECT name, arn_pattern FROM resource_types
WHERE service_id = (SELECT service_id FROM services WHERE prefix = 's3');
```

**Find conditions for resource type:**

```sql
SELECT ck.name, ck.type, ck.description
FROM condition_keys ck
JOIN resource_types_condition_keys rtck ON ck.condition_key_id = rtck.condition_key_id
JOIN resource_types rt ON rtck.resource_type_id = rt.resource_type_id
WHERE rt.name = 'bucket';
```

## Access Levels

- **List** - Read-only permissions to list resources
- **Read** - Read-only permissions to read resource details
- **Write** - Create, update, or delete resources
- **Tagging** - Permissions to tag resources
- **Permissions management** - Permissions to grant or modify permissions

---

# Troubleshooting

## Empty Results When Expecting Data

**Problem:** Query returns 0 rows for conditions

**Solution:** Check resource-type level instead of action level:

```sql
-- Instead of: actions_condition_keys
-- Use: resource_types_condition_keys
```

## Action Not Found

**Problem:** Can't find action like "DeleteDBInstance"

**Solution:** Include service prefix:

```sql
-- Wrong: WHERE name = 'DeleteDBInstance'
-- Right: WHERE name = 'rds:DeleteDBInstance'
```

## Too Many Results

**Problem:** Query returns thousands of rows

**Solution:** Add LIMIT and filters:

```sql
-- Add LIMIT
SELECT * FROM actions LIMIT 50;

-- Add service filter
SELECT * FROM actions
WHERE service_id = (SELECT service_id FROM services WHERE prefix = 'rds')
LIMIT 50;
```

## Can't Match ARN to Resource Type

**Problem:** ARN doesn't match any patterns

**Solution:** Parse ARN components and query:

```sql
-- Extract service from ARN (arn:aws:SERVICE:...)
-- Query resource types for that service
SELECT name, arn_pattern
FROM resource_types
WHERE service_id = (SELECT service_id FROM services WHERE prefix = 'EXTRACTED_SERVICE');
```

---

Remember: The database is the authoritative source. When in doubt, query!
