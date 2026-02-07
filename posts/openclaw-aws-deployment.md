---
title: "How I Deployed OpenClaw AI Agent on AWS for $2/month"
published: false
description: "A beginner-friendly guide to running OpenClaw (Clawdbot AI) on AWS without expensive Mac hardware"
tags: aws, ai, cloudformation, tutorial
---

## The Problem

I wanted to use OpenClaw (formerly Clawdbot AI) for my AI agent experiments, but I didn't want to:

- Buy an expensive Mac mini just for this
- Keep my personal machine running 24/7
- Deal with security concerns of running AI on my main computer

So I figured out how to deploy it on AWS for around $2/month. Here's how you can do it too!

## Why Cloud Deployment?

| Local Setup | Cloud Setup |
|-------------|-------------|
| Need dedicated hardware | No hardware needed |
| Only accessible from home | Access from anywhere |
| Power costs add up | Pay only for what you use |
| Security concerns | Isolated environment |

## What You'll Need

- An AWS account (free to create)
- An LLM provider API key (OpenRouter has a free tier!)
- About 10 minutes of your time

## Step 1: Deploy the CloudFormation Stack (5 mins)

The easiest way is using CloudFormation, which sets up everything automatically.

```bash
aws cloudformation create-stack \
  --stack-name openclaw-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM
```

Or through the AWS Console:

1. Go to CloudFormation
2. Click "Create Stack"
3. Upload the template
4. Give it a name and click "Create"

Wait about 5 minutes for the resources to provision.

## Step 2: Configure the Agent

SSH into your new EC2 instance and run the setup:

```bash
ssh -i your-key.pem ec2-user@your-instance-ip
```

You'll be prompted for:

- **Operation mode**: Choose "Local"
- **LLM Provider**: I recommend OpenRouter (has free tier)
- **Model**: Pick one like `gpt-oss-120b:free`

## Step 3: Access Your Agent

Once configured, you'll get a URL. Open it in your browser and start chatting with your AI agent!

## Cost Breakdown

Here's what it actually costs:

| Usage | Monthly Cost |
|-------|-------------|
| 8 hours/day | ~$2 |
| 24/7 | ~$6 |

Plus LLM costs (free with OpenRouter's free tier).

## Pro Tips

### Save Money with Spot Instances

You can cut costs by up to 90% using Spot Instances. Just be aware they can be interrupted.

### Stop When Not Using

Unlike a Mac mini that's always on, you can stop your EC2 instance when you're not using it. No charges while it's stopped!

### Use Scheduled Actions

Set up CloudWatch Events to automatically start/stop your instance:

```yaml
# Start at 8 AM, stop at 10 PM
StartAction: "0 8 * * *"
StopAction: "0 22 * * *"
```

## Common Issues

**Can't SSH into instance?**
- Check your Security Group allows port 22
- Make sure you're using the right key pair

**URL not working?**
- Ensure ports 80/443 are open in Security Group
- Verify the instance is running

**Stack creation failed?**
- Check IAM permissions
- Don't forget `CAPABILITY_IAM` flag

## Wrapping Up

Running OpenClaw on AWS is:
- 💰 Cheap (~$2/month)
- 🚀 Quick to set up (~10 mins)
- 🌍 Accessible from anywhere
- 🔒 Isolated from your personal machine

Give it a try and let me know how it goes in the comments!

## Resources

- [OpenClaw GitHub](https://github.com/openclaw)
- [AWS CloudFormation Docs](https://docs.aws.amazon.com/cloudformation/)
- [OpenRouter](https://openrouter.ai/) for free LLM access

---

*Have questions? Drop them in the comments!*
