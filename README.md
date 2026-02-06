# devto-article

DEV.to記事公開用リポジトリ

## 概要

このリポジトリはDEV.toへの記事公開を管理します。
- **PR作成**: 記事を下書き（unpublished）で投稿
- **PRマージ**: 記事を公開（published）に変更

## ディレクトリ構成

```
devto-article/
├── posts/              # 記事
├── scripts/            # デプロイスクリプト
├── .github/workflows/  # GitHub Actions
└── devto_article_ids.json  # 記事ID管理
```

## ワークフロー

| イベント | アクション | DEV.to状態 |
|----------|-----------|----------|
| PR作成・更新 | published: false で投稿 | Draft |
| PRマージ | published: true で投稿 | Published |

## 記事の作成

`posts/` ディレクトリにMarkdownファイルを作成します。

## Frontmatter

```yaml
---
title: "記事タイトル"
description: "記事の説明"
tags:
  - javascript
  - webdev
cover_image: "https://example.com/image.jpg"
canonical_url: ""
---
```

## 必要な設定

### GitHub Secrets
- `DEVTO_API_KEY`: DEV.to APIキー（必須）
- `DISCORD_WEBHOOK`: Discord通知用Webhook URL（オプション）

### APIキー取得方法
1. [DEV.to](https://dev.to) にログイン
2. [Settings → Extensions](https://dev.to/settings/extensions) を開く
3. 「DEV Community API Keys」で「Generate API Key」
4. 生成されたキーをGitHub Secretsに設定

## 関連リンク

- [granizm-blog](https://github.com/granizm/granizm-blog) - アイデア・下書き管理
- [DEV.to API](https://developers.forem.com/api)
