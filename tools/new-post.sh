#!/usr/bin/env bash

set -eu

if [ $# -lt 1 ]; then
  echo "Usage: bash tools/new-post.sh \"Post Title\" [category] [tags] [image_url]"
  echo
  echo "Example:"
  echo "  bash tools/new-post.sh \"Easiest 2FA Bypass\" \"CATEGORY\" \"TAG, TAG\" \"<GIF SOURCE>\""
  exit 1
fi

title="$1"
category="${2:-Web Security}"
tags="${3:-Web Security, Writeups}"
image="${4:-<GIF_OR_IMAGE_HERE}"

date_prefix="$(date '+%Y-%m-%d')"
post_date="$(date '+%Y-%m-%d %H:%M:%S %z')"

slug="$(printf '%s' "$title" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

file="_posts/${date_prefix}-${slug}.md"

if [ -e "$file" ]; then
  echo "Post already exists: $file"
  exit 1
fi

mkdir -p _posts

{
  echo "---"
  echo "title: \"$title\""
  echo "date: $post_date"
  echo "categories: [$category]"
  echo "tags: [$tags]"
  echo "image:"
  echo "  path: $image"
  echo "---"
  echo
  echo "# Introduction"
  echo
  echo "Write the opening here."
  echo
  echo "# Story"
  echo
  echo "Add the context, what happened, and why this was interesting."
  echo
  echo "# Technical Breakdown"
  echo
  echo "Explain the steps, observations, payloads, commands, or logic."
  echo
  echo '```console'
  echo '$ command here'
  echo '```'
  echo
  echo "# What I Learned"
  echo
  echo "Summarize the main lesson."
  echo
  echo "# What's Next?"
  echo
  echo "Close the post with what you plan to study, test, or write next."
} > "$file"

echo "Created: $file"
