---
title: "How I Run OpenClaw on AWS for $2/month (No Mac Required!)"
published: false
description: "Skip the expensive hardware - here's how to run your AI agent in the cloud for just $2 a month"
tags: aws, ai, tutorial, beginners
---

## The Problem

I wanted to run OpenClaw (formerly Clawdbot AI) 24/7, but I didn't want to:

- Buy a Mac mini ($700+)
- Keep my computer running all day
- Worry about security on my home network

So I put it on AWS instead. **Total cost: about $2/month.**

Here's how I did it.

## Why Cloud?

| | Local (Mac mini) | Cloud (AWS) |
|---|---|---|
| Upfront cost | $700+ | $0 |
| Monthly cost | Electricity | ~$2 |
| Access | Home only | Anywhere |
| Uptime | When PC is on | 24/7 |

If you just want to try OpenClaw without committing to expensive hardware, AWS is the way to go.

## Setup in 3 Steps (10 minutes)

### Step 1: Deploy to AWS (~5 min)

Use the CloudFormation template to spin up an EC2 instance.

1. Go to AWS Console
2. Navigate to CloudFormation
3. Create a new stack with the template
4. Wait ~3 minutes

That's it. Your server is ready.

### Step 2: Configure OpenClaw

SSH into your new instance:

```bash
ssh -i your-key.pem ec2-user@<your-instance-ip>
```

Run the setup:

```bash
openclaw_setup
```

When prompted, choose:
- **Operation Mode**: Local
- **LLM Provider**: OpenRouter
- **Model**: gpt-oss-120b:free (it's free!)

### Step 3: Start Using It

Open the URL that appears after setup. You're now chatting with your own AI agent!

## Cost Breakdown

| Usage | Cost |
|-------|------|
| 8 hours/day | ~$0.07/day |
| 24/7 | ~$2/month |

**LLM costs**: Zero if you use the free model. If you want better models, pay-as-you-go.

## Heads Up

> ⚠️ This setup is great for testing and personal use. For production, you'll want to add proper security measures.

Things to consider:
- Lock down your security groups
- Manage your SSH keys properly
- Delete the stack when you're done to save money

## Wrapping Up

Running OpenClaw on AWS is:
- **Cheap**: ~$2/month
- **Easy**: 10-minute setup
- **Flexible**: Access from anywhere

No need to buy a Mac mini just to try AI agents. Give this a shot!

---

*Questions? Drop them in the comments!*

## Resources

- [Original article (Japanese)](https://note.com/granizm/n/n83515660ed41)
