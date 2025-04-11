# Quick Start Guide for Gensyn RL-Swarm

> [!WARNING]
> Right now, this doesn’t connect on-chain. I’m planning to update it with a proper solution in the next few days. Same goal — make it work with the least amount of steps and thinking for the user.

Use **Jupyter Lab CUDA 12.6** template on [QuickPod](https://console.quickpod.io/templates)

## Creating the Pod
1. You can choose 3090, 4090, 5090, A5000

   ![image](https://github.com/user-attachments/assets/a86b55ff-f4a9-4cbc-bb45-ea36257b3e98)

3. Click the orange button `Connect to JupyterLab`

   ![image](https://github.com/user-attachments/assets/e797c4c3-f8ec-4b43-8ae2-72b29dc13561)

4. Open a new terminal

   ![image](https://github.com/user-attachments/assets/d304639d-a46b-4c8a-8263-4e3355c6c867)


## Setup
0. Drag your `swarm.pem` on the left side if you have one. If you don't have yet, skip to step 1
   
   ![image](https://github.com/user-attachments/assets/e2ea0a54-5514-490f-957b-783fd339da74)

2. Run this command to install everything:
   ```
   curl -s https://quickpod.github.io/gensyn/init.sh | bash
   ```
   ![image](https://github.com/user-attachments/assets/80bf41cc-54a8-4106-929a-0b3b1065e355)

3. Wait for the setup to complete. This may take a few minutes.
4. Run the Gensyn Node:
   It will create a `swarm.pem` if you don't have yet else it will use the one you uploaded on step 0
   ```
   ./run.sh
   ```
   ![image](https://github.com/user-attachments/assets/efd2297e-6c32-400a-b5ae-160f80a8e8a0)

> [!NOTE]
> You can close the browser tab and your node will still run. Just open JupyterLab again next time if you want to check on it

## Backup Your Identity
After running successfully, download the `swarm.pem` file for future use:
1. Right-click on the `swarm.pem` file
2. Select "Download" to save it to your computer

## Check your node status at 
https://quickpod.github.io/gensyn

![image](https://github.com/user-attachments/assets/18413ca6-7369-4795-8993-963b70d1999b)

![image](https://github.com/user-attachments/assets/216509e7-3b21-49c2-822a-32bb287213c4)

