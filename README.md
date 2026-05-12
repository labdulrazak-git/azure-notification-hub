# Azure Notification Hub Automated Deployment

## 🎯 Overview
This project provides an automated Bash script to deploy a **Microsoft Azure Notification Hub** environment. It follows the Azure Well-Architected Framework by implementing unique resource naming and organized resource grouping.

## 🏗️ Architecture
The script deploys the following hierarchy:
1. **Resource Group**: Logical container for all resources.
2. **Notification Hub Namespace**: The DNS endpoint and container.
3. **Notification Hub**: The engine for sending push notifications.

## 🚀 How to Use
1. **Prerequisites**: 
   - Azure CLI installed.
   - Active Azure Subscription.
   - Logged in via `az login`.
2. **Run Deployment**:
   ```bash
   chmod +x myscript.sh
   ./myscript.sh
