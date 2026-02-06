#!/bin/bash
# Publish articles to DEV.to using Forem API
# Usage: ./scripts/publish.sh
# Note: published status is read from frontmatter (published: true/false)

set -e

echo "=== Script started ==="
echo "PWD: $(pwd)"
echo "Shell: $SHELL"
echo "Bash version: $BASH_VERSION"

API_URL="https://dev.to/api/articles"
IDS_FILE="devto_article_ids.json"

# Initialize IDs file if not exists
if [ ! -f "$IDS_FILE" ]; then
  echo "{}" > "$IDS_FILE"
fi

# Check API key
if [ -z "$DEVTO_API_KEY" ]; then
  echo "Error: DEVTO_API_KEY is not set"
  exit 1
fi

# Parse frontmatter
parse_frontmatter() {
  local file="$1"
  local key="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${key}:" | sed "s/^${key}:[[:space:]]*//" | tr -d '"'
}

# Get article body (after frontmatter)
get_body() {
  local file="$1"
  sed '1,/^---$/d' "$file" | sed '1,/^---$/d'
}

# Get tags as array
get_tags() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" | grep -A100 "^tags:" | grep "^  - " | sed 's/^  - //' | tr -d '"' | head -4
}

for file in posts/*.md; do
  if [ ! -f "$file" ] || [ "$file" = "posts/.gitkeep" ]; then
    continue
  fi

  filename=$(basename "$file" .md)
  echo "Processing: $file"
  echo "=== File exists check ==="
  ls -la "$file"
  echo "=== Raw content ==="
  head -20 "$file"

  # Extract metadata
  echo "=== Extracting title ==="
  title=$(parse_frontmatter "$file" "title")
  echo "Title: $title"
  description=$(parse_frontmatter "$file" "description")
  canonical_url=$(parse_frontmatter "$file" "canonical_url")
  cover_image=$(parse_frontmatter "$file" "cover_image")
  body=$(get_body "$file")

  # Get tags
  echo "=== Getting tags ==="
  raw_tags=$(get_tags "$file")
  echo "Raw tags: $raw_tags"
  if [ -n "$raw_tags" ]; then
    tags=$(echo "$raw_tags" | jq -R -s -c 'split("\n") | map(select(length > 0))')
  else
    tags="[]"
  fi
  echo "Tags JSON: $tags"

  # Set published status from frontmatter (default: false for safety)
  frontmatter_published=$(parse_frontmatter "$file" "published")
  if [ "$frontmatter_published" = "true" ]; then
    published="true"
  else
    published="false"
  fi

  # Check if article already exists
  article_id=$(jq -r ".\"$filename\" // empty" "$IDS_FILE")

  # Build JSON payload
  json_payload=$(jq -n \
    --arg title "$title" \
    --arg body "$body" \
    --argjson published "$published" \
    --argjson tags "$tags" \
    --arg description "$description" \
    --arg canonical_url "$canonical_url" \
    --arg cover_image "$cover_image" \
    '{
      article: {
        title: $title,
        body_markdown: $body,
        published: $published,
        tags: $tags,
        description: (if $description != "" and $description != "null" then $description else null end),
        canonical_url: (if $canonical_url != "" and $canonical_url != "null" then $canonical_url else null end),
        main_image: (if $cover_image != "" and $cover_image != "null" then $cover_image else null end)
      }
    }')

  if [ -n "$article_id" ]; then
    # Update existing article
    echo "Updating article ID: $article_id"
    response=$(curl -s -X PUT "$API_URL/$article_id" \
      -H "Content-Type: application/json" \
      -H "api-key: $DEVTO_API_KEY" \
      -d "$json_payload")
  else
    # Create new article
    echo "Creating new article"
    response=$(curl -s -X POST "$API_URL" \
      -H "Content-Type: application/json" \
      -H "api-key: $DEVTO_API_KEY" \
      -d "$json_payload")

    # Save article ID
    new_id=$(echo "$response" | jq -r '.id // empty')
    if [ -n "$new_id" ]; then
      jq --arg filename "$filename" --arg id "$new_id" \
        '.[$filename] = ($id | tonumber)' "$IDS_FILE" > tmp.json && mv tmp.json "$IDS_FILE"
      echo "Saved article ID: $new_id"
    fi
  fi

  # Check for errors
  error=$(echo "$response" | jq -r '.error // empty')
  if [ -n "$error" ]; then
    echo "Error: $error"
    exit 1
  fi

  url=$(echo "$response" | jq -r '.url // empty')
  echo "Article URL: $url"
done

echo "Done!"
