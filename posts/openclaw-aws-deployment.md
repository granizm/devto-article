---
title: "How I Deployed OpenClaw AI Agent on AWS with Amazon Bedrock"
published: false
description: "A practical guide to running OpenClaw on AWS using Amazon Bedrock - no API keys required"
tags: aws, ai, bedrock, tutorial
---

## The Problem I Wanted to Solve

I wanted to use OpenClaw (formerly Clawdbot AI) for my AI agent experiments, but I didn't want to:

- Buy an expensive Mac mini just for this
- Manage multiple API keys for LLM providers
- Deal with security concerns of running AI on my personal machine

So I found the official AWS sample that deploys OpenClaw with **Amazon Bedrock**. Here's what I learned!

> **Important Note:** This article is based on the official AWS sample repository: [aws-samples/sample-OpenClaw-on-AWS-with-Bedrock](https://github.com/aws-samples/sample-OpenClaw-on-AWS-with-Bedrock)

## Why Amazon Bedrock?

The killer feature is **no API key management**. Instead of juggling multiple API keys from different LLM providers, you get:

- **IAM-based authentication** - Your AWS credentials handle everything
- **Multiple model options** - Nova, Claude, DeepSeek, Llama (8 models total!)
- **Enterprise-grade security** - VPC Endpoints for private communication

## Architecture Overview

```
User → WhatsApp/Telegram → EC2 (OpenClaw) → Amazon Bedrock
                              ↓
                        VPC Endpoints
                              ↓
                          CloudTrail
```

CloudFormation provisions these resources automatically:

| Service | Purpose |
|---------|---------|
| EC2 (t4g.medium) | Runs OpenClaw (Graviton ARM) |
| Amazon Bedrock | AI model API |
| IAM Role | Bedrock authentication |
| VPC Endpoints | Private network access |
| CloudTrail | API audit logging |
| SSM Session Manager | Secure access (no SSH needed) |

## Prerequisites

Before you start, you'll need:

1. **AWS account** with appropriate permissions
2. **Bedrock models enabled** - Go to AWS Console → Bedrock → Model access
3. **EC2 Key Pair** (optional if using SSM Session Manager)

## Step 1: One-Click Deploy (~8 minutes)

The easiest way is clicking "Launch Stack" in the official repo. It sets up everything automatically.

```bash
# Or via CLI if you prefer:
aws cloudformation create-stack \
  --stack-name openclaw-bedrock \
  --template-url https://[S3-URL]/template.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters \
    ParameterKey=KeyName,ParameterValue=your-keypair
```

Wait about **8 minutes** for the stack to complete.

## Step 2: Get Your Access Credentials

Check the CloudFormation Outputs tab for:
- **Access URL**
- **Authentication token**

## Step 3: Connect via SSM Session Manager

```bash
# Port forwarding to access the UI
aws ssm start-session \
  --target i-xxxxxxxxx \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["18789"],"localPortNumber":["18789"]}'
```

Open `http://localhost:18789` in your browser and you're in!

## Available AI Models

You can choose from 8 models in Bedrock:

- **Nova 2 Lite** (recommended - cheapest)
- **Nova Pro**
- **Claude Sonnet**
- **DeepSeek**
- **Llama**
- And more...

## Real Cost Breakdown

> **Correction:** I initially thought this would cost ~$2/month. I was wrong! Here's the actual breakdown.

### Infrastructure Costs (Monthly)

| Component | Cost |
|-----------|------|
| EC2 (t4g.medium) | $24.19 |
| EBS (gp3, 30GB) | $2.40 |
| VPC Endpoints | $21.60 |
| Data Transfer | $5-10 |
| **Subtotal** | **$53-58** |

### Bedrock Usage (Per Million Tokens)

| Model | Input | Output |
|-------|-------|--------|
| Nova 2 Lite | $0.30 | $2.50 |
| Nova Pro | $0.80 | $3.20 |
| Claude Sonnet | $3.00 | $15.00 |

**Total monthly cost: ~$58-66** for light usage

## Instance Type Options

### Linux (Recommended)

| Type | RAM | Monthly Cost |
|------|-----|-------------|
| t4g.small | 2GB | $12 |
| t4g.medium (default) | 4GB | $24 |
| t4g.large | 8GB | $48 |

### macOS (For iOS/macOS Development)

| Type | Chip | RAM | Monthly Cost |
|------|------|-----|-------------|
| mac2.metal | M1 | 16GB | $468 |
| mac2-m2.metal | M2 | 24GB | $632 |

## Supported Messaging Platforms

OpenClaw works with:

- **WhatsApp** (recommended)
- **Telegram**
- **Discord**
- **Slack**
- **Microsoft Teams**

## Cost-Saving Tips

### Stop When Not Using

EC2 charges stop when the instance is stopped. However, **VPC Endpoints continue charging** even when your instance is down!

### Use a Smaller Instance

t4g.small ($12/month) works for light usage with 2GB RAM.

### Choose Nova 2 Lite

It's the cheapest Bedrock model at $0.30/million input tokens.

### Consider Removing VPC Endpoints

If you're okay with public Bedrock access, you can skip VPC Endpoints and save ~$22/month. Check security implications first though.

## Common Issues

**Stack creation failed?**
- Check IAM permissions
- Make sure Bedrock models are enabled
- Don't forget `CAPABILITY_IAM` flag

**SSM Session Manager not working?**
- Verify the instance has SSM agent installed
- Check IAM role has SSM permissions

**Bedrock model not available?**
- Enable models in AWS Console → Bedrock → Model access
- Check your region supports Bedrock (us-east-1, us-west-2, etc.)

## Wrapping Up

Running OpenClaw on AWS with Bedrock gives you:

- No more API key juggling
- Enterprise security out of the box
- Access from anywhere
- 8 AI models to choose from

The trade-off is cost: expect **~$53-58/month minimum** for infrastructure, plus Bedrock usage.

It takes about **8 minutes to deploy** with one click. Give it a try!

## Resources

- [OpenClaw on AWS with Bedrock (Official AWS Sample)](https://github.com/aws-samples/sample-OpenClaw-on-AWS-with-Bedrock)
- [Amazon Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [AWS CloudFormation Docs](https://docs.aws.amazon.com/cloudformation/)

---

*Have questions or corrections? Drop them in the comments!*
