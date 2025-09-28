#!/bin/bash

# Deploy Security Configuration Script
# This script deploys Firestore security rules and indexes

set -e

echo "🔒 Deploying Security Configuration..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please login first:"
    echo "firebase login"
    exit 1
fi

# Get current project
PROJECT_ID=$(firebase use --json | jq -r '.result.project // empty')
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No Firebase project selected. Please select a project:"
    echo "firebase use <project-id>"
    exit 1
fi

echo "📋 Current project: $PROJECT_ID"

# Validate Firestore rules syntax
echo "🔍 Validating Firestore rules..."
if ! firebase firestore:rules --help &> /dev/null; then
    echo "❌ Firestore rules command not available. Please update Firebase CLI."
    exit 1
fi

# Deploy Firestore rules
echo "🚀 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed successfully"
else
    echo "❌ Failed to deploy Firestore rules"
    exit 1
fi

# Deploy Firestore indexes
echo "🚀 Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo "✅ Firestore indexes deployed successfully"
else
    echo "❌ Failed to deploy Firestore indexes"
    exit 1
fi

echo "🎉 Security configuration deployed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Test the security rules in the Firebase console"
echo "2. Monitor security events in the application logs"
echo "3. Review and update rules as needed"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID/firestore"