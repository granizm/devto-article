#!/bin/bash
# Publish articles to DEV.to using Forem API
# Usage: ./scripts/publish.sh
# Note: published status is read from frontmatter (published: true/false)

set -e

echo "=== Script Starting ==="
echo "PWD: $(pwd)"
echo "jq version: $(jq --version)"

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

# Parse frontmatter (returns empty string for null values)
parse_frontmatter() {
  local file="$1"
  local key="$2"
  local value=""
  value=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^${key}:" | head -1 | sed "s/^${key}:[[:space:]]*//" | tr -d '"' || echo "")
  # Return empty string if value is "null" or empty
  if [ "$value" = "null" ] || [ -z "$value" ]; then
    echo ""
  else
    echo "$value"
  fi
}

# Get article body (after frontmatter)
get_body() {
  local file="$1"
  sed '1,/^---$/d' "$file" | sed '1,/^---$/d'
}

# Get tags as JSON array
get_tags_json() {
  local file="$1"
  local tags_list
  tags_list=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^  - " | sed 's/^  - //' | tr -d '"' | head -4 || echo "")
  if [ -n "$tags_list" ]; then
    echo "$tags_list" | jq -R -s -c 'split("\n") | map(select(length > 0))'
  else
    echo "[]"
  fi
}

echo "=== Listing posts ==="
ls -la posts/

for file in posts/*.md; do
  if [ ! -f "$file" ]; then
    echo "Skipping: $file (not a file)"
    continue
  fi

  if [ "$file" = "posts/.gitkeep" ]; then
    echo "Skipping: .gitkeep"
    continue
  fi

  filename=$(basename "$file" .md)
  echo ""
  echo "=== Processing: $file ==="

  # Extract metadata
  echo "Extracting title..."
  title=$(parse_frontmatter "$file" "title")
  echo "Title: $title"

  echo "Extracting description..."
  description=$(parse_frontmatter "$file" "description")
  echo "Description: $description"

  echo "Extracting canonical_url..."
  canonical_url=$(parse_frontmatter "$file" "canonical_url")

  echo "Extracting cover_image..."
  cover_image=$(parse_frontmatter "$file" "cover_image")

  echo "Extracting body..."
  body=$(get_body "$file")
  echo "Body length: ${#body} chars"

  # Get tags
  echo "Extracting tags..."
  tags=$(get_tags_json "$file")
  echo "Tags: $tags"

  # Set published status from frontmatter (default: false for safety)
  echo "Extracting published status..."
  frontmatter_published=$(parse_frontmatter "$file" "published")
  if [ "$frontmatter_published" = "true" ]; then
    published="true"
  else
    published="false"
  fi
  echo "Published: $published"

  # Check if article already exists
  echo "Checking if article exists..."
  article_id=$(jq -r ".\"$filename\" // empty" "$IDS_FILE" || echo "")
  echo "Article ID: ${article_id:-none}"

  # Build JSON payload
  echo "Building JSON payload..."
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
        description: (if $description != "" then $description else null end),
        canonical_url: (if $canonical_url != "" then $canonical_url else null end),
        main_image: (if $cover_image != "" then $cover_image else null end)
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
    echo "Creating new article..."
    response=$(curl -s -X POST "$API_URL" \
      -H "Content-Type: application/json" \
      -H "api-key: $DEVTO_API_KEY" \
      -d "$json_payload")

    # Save article ID
    new_id=$(echo "$response" | jq -r '.id // empty' || echo "")
    if [ -n "$new_id" ]; then
      echo "Saving article ID: $new_id"
      jq --arg filename "$filename" --arg id "$new_id" \
        '.[$filename] = ($id | tonumber)' "$IDS_FILE" > tmp.json && mv tmp.json "$IDS_FILE"
    fi
  fi

  # Check for errors
  error=$(echo "$response" | jq -r '.error // empty' || echo "")
  if [ -n "$error" ]; then
    echo "API Error: $error"
    echo "Response: $response"
    exit 1
  fi

  url=$(echo "$response" | jq -r '.url // empty' || echo "")
  echo "Article URL: $url"
done

echo ""
echo "=== Done! ==="
