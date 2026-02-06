#!/bin/bash
# Publish articles to DEV.to using Forem API
# Usage: ./scripts/publish.sh
# Note: published status is read from frontmatter (published: true/false)

# Don't exit on error - we handle errors explicitly
set +e

echo "=== Script Starting ==="
echo "PWD: $(pwd)"

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

echo "jq version: $(jq --version)"

# Parse frontmatter (returns empty string for null/missing values)
parse_frontmatter() {
  local file="$1"
  local key="$2"
  local frontmatter
  local value

  # Extract frontmatter section
  frontmatter=$(sed -n '1,/^---$/!{/^---$/,/^---$/p}' "$file" 2>/dev/null | sed '1d;$d')

  # Get value for key
  value=$(echo "$frontmatter" | grep "^${key}:" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | tr -d '"' | head -1)

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
  awk 'BEGIN{p=0} /^---$/{p++; next} p>=2{print}' "$file" 2>/dev/null
}

# Get tags as JSON array
get_tags_json() {
  local file="$1"
  local tags=""

  # Extract tags from frontmatter
  tags=$(sed -n '/^tags:/,/^[a-z]/p' "$file" 2>/dev/null | grep "^  - " | sed 's/^  - //' | tr -d '"' | head -4)

  if [ -z "$tags" ]; then
    echo "[]"
  else
    echo "$tags" | jq -R -s -c 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]"
  fi
}

echo "=== Processing articles ==="

for file in posts/*.md; do
  # Skip non-files and .gitkeep
  if [ ! -f "$file" ]; then
    continue
  fi

  filename=$(basename "$file" .md)

  if [ "$filename" = ".gitkeep" ]; then
    continue
  fi

  echo ""
  echo "=== Processing: $file ==="

  # Extract metadata
  title=$(parse_frontmatter "$file" "title")
  echo "Title: $title"

  description=$(parse_frontmatter "$file" "description")
  echo "Description: $description"

  body=$(get_body "$file")
  echo "Body length: ${#body} chars"

  # Get tags
  tags=$(get_tags_json "$file")
  echo "Tags: $tags"

  # Set published status from frontmatter (default: false for safety)
  frontmatter_published=$(parse_frontmatter "$file" "published")
  if [ "$frontmatter_published" = "true" ]; then
    published="true"
  else
    published="false"
  fi
  echo "Published: $published"

  # Check if article already exists
  article_id=$(jq -r ".\"$filename\" // empty" "$IDS_FILE" 2>/dev/null)
  echo "Existing ID: ${article_id:-none}"

  # Build JSON payload
  json_payload=$(jq -n \
    --arg title "$title" \
    --arg body "$body" \
    --argjson published "$published" \
    --argjson tags "$tags" \
    --arg description "$description" \
    '{
      article: {
        title: $title,
        body_markdown: $body,
        published: $published,
        tags: $tags,
        description: (if $description != "" then $description else null end)
      }
    }' 2>/dev/null)

  if [ -z "$json_payload" ]; then
    echo "ERROR: Failed to build JSON payload"
    continue
  fi

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
    new_id=$(echo "$response" | jq -r '.id // empty' 2>/dev/null)
    if [ -n "$new_id" ]; then
      jq --arg filename "$filename" --arg id "$new_id" \
        '.[$filename] = ($id | tonumber)' "$IDS_FILE" > tmp.json 2>/dev/null && mv tmp.json "$IDS_FILE"
      echo "Saved article ID: $new_id"
    fi
  fi

  # Check for errors
  error=$(echo "$response" | jq -r '.error // empty' 2>/dev/null)
  if [ -n "$error" ]; then
    echo "API Error: $error"
    echo "Response: $response"
    # Don't exit, continue with next article
  else
    url=$(echo "$response" | jq -r '.url // empty' 2>/dev/null)
    echo "Article URL: $url"
  fi
done

echo ""
echo "=== Done! ==="
