#!/bin/bash

# Configuration
API_KEY="AIzaSyAPm59HesfNtYYt88NjDW46XOjFvWMwHU4" # iOS API Key from firebase_options.dart
EMAIL="apple.review@aqvioo.com"
PASSWORD="AqviooReview2026!"
PROJECT_ID="beldify-b445b"

echo "🚀 Starting App Store Reviewer Seeding..."

# 1. Sign up user
echo "👤 Creating Firebase Auth user..."
SIGNUP_RESPONSE=$(curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\", \"password\":\"$PASSWORD\", \"returnSecureToken\":true}")

# Check if signup was successful
LOCAL_ID=$(echo $SIGNUP_RESPONSE | grep -o '"localId": *"[^"]*"' | cut -d'"' -f4)
ID_TOKEN=$(echo $SIGNUP_RESPONSE | grep -o '"idToken": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$LOCAL_ID" ]; then
    echo "❌ Error creating user: $SIGNUP_RESPONSE"
    exit 1
fi

echo "✅ User created successfully (UID: $LOCAL_ID)"

# 2. Create Firestore Profile
# Using the ID token for authentication
echo "📄 Initializing Firestore profile..."
PROFILE_DATA="{\"fields\": {
  \"displayName\": {\"stringValue\": \"Apple Reviewer\"},
  \"email\": {\"stringValue\": \"$EMAIL\"},
  \"status\": {\"stringValue\": \"active\"},
  \"isAnonymous\": {\"booleanValue\": false},
  \"createdAt\": {\"timestampValue\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
  \"lastLoginAt\": {\"timestampValue\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}
}}"

curl -s -X PATCH "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/users/$LOCAL_ID?key=$API_KEY" \
  -H "Authorization: Bearer $ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PROFILE_DATA" > /dev/null

echo "✅ Profile initialized"

# 3. Create Credits Document
echo "💰 Seeding test balance (500 SAR)..."
CREDITS_DATA="{\"fields\": {
  \"balance\": {\"doubleValue\": 500.0},
  \"credits\": {\"integerValue\": \"500\"},
  \"hasGeneratedFirst\": {\"booleanValue\": false},
  \"lastUpdated\": {\"timestampValue\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}
}}"

curl -s -X PATCH "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/users/$LOCAL_ID/data/credits?key=$API_KEY" \
  -H "Authorization: Bearer $ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$CREDITS_DATA" > /dev/null

echo "✅ Balance seeded successfully"
echo "🎉 Seeding complete. You can now use $EMAIL / $PASSWORD for review."
