#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration ---
NAMESPACE="argocd"
SERVER="localhost:1443" # Updated to reflect your actual port
ACCOUNT="apiUser"
# ---------------------

echo "⚙️  Step 1: Patching argocd-cm to add API account '$ACCOUNT'..."
kubectl patch configmap/argocd-cm -n "$NAMESPACE" \
  --type merge \
  -p "{\"data\":{\"accounts.$ACCOUNT\":\"apiKey\"}}"

echo "⚙️  Step 2: Patching argocd-rbac-cm to grant 'role:admin' to '$ACCOUNT'..."
kubectl patch configmap/argocd-rbac-cm -n "$NAMESPACE" \
  --type merge \
  -p "{\"data\":{\"policy.csv\":\"g, $ACCOUNT, role:admin\n\"}}"

echo "🔐 Step 3: Retrieving initial admin password..."
ADMIN_PASSWORD=$(kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "🔑 Step 4: Logging into ArgoCD CLI at $SERVER..."
# Temporarily disable 'exit on error' so we can manually catch the failure
set +e
LOGIN_OUTPUT=$(argocd login "$SERVER" --insecure --username admin --password "$ADMIN_PASSWORD" 2>&1)
LOGIN_EXIT_CODE=$?
# Re-enable 'exit on error'
set -e

# Catch the error and print a helpful message
if [ $LOGIN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ CONNECTION FAILED: Could not log into ArgoCD."
    echo "=================================================="
    echo "The script could not reach ArgoCD at '$SERVER'."
    echo "Ensure your port-forwarding is actively running in another terminal."
    echo "Example: kubectl port-forward svc/argocd-server -n $NAMESPACE 1443:443"
    echo "--------------------------------------------------"
    echo "Diagnostic Output from ArgoCD CLI:"
    echo "$LOGIN_OUTPUT"
    echo "--------------------------------------------------"
    echo "Since we successfully retrieved the password, here it is so you don't lose it:"
    echo "👤 Admin Password: $ADMIN_PASSWORD"
    exit 1
fi

echo "🎫 Step 5: Generating API token for '$ACCOUNT' (expires in 90 days)..."
API_TOKEN=$(argocd account generate-token --account "$ACCOUNT" --expires-in 2160h)

echo ""
echo "=================================================="
echo "✅ Setup Complete!"
echo "=================================================="
echo "👤 Admin Password: $ADMIN_PASSWORD"
echo "🪙  API Token:      $API_TOKEN"
echo "=================================================="
echo "ℹ️  Your local ArgoCD CLI is now authenticated as admin and ready to use."