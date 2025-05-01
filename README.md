# 🐝 Quick Start: Gensyn RL-Swarm on QuickPod  
**Last updated:** May 1, 2025

---

## 1. Create Your Pod

1. Go to [QuickPod Templates](https://console.quickpod.io/templates)  
2. Find **`Jupyter Lab CUDA 12.6`**, click **Clone**, and name it (e.g., `Gensyn 12.6`)

   ![image](https://github.com/user-attachments/assets/bb3b85bf-9eee-41d3-95a5-40d8fbc95878)

3. In the Docker settings, add:
   ```
   -p 3000:3000 --shm-size=16g
   ```
   Then click **Save**.

   ![msedge_uOQO96e36Z](https://github.com/user-attachments/assets/3c9aa89e-33e2-4b92-a92e-d2e15ea09679)

4. Choose a machine:
   - **CPU:** 16GB+ RAM  
   - **GPU:** 16GB+ RAM (VRAM can be less or more than 24GB)

   Select the template you just created.

   ![image](https://github.com/user-attachments/assets/31ab3b50-1908-4425-b660-7072eb936b64)

5. Click the orange **Connect to JupyterLab** button.

   ![image](https://github.com/user-attachments/assets/4748f432-5be1-47e6-8cfb-a9d5aeb4720b)

---

## 2. Open a Terminal

Inside JupyterLab, click the **Terminal** icon on the left.

![image](https://github.com/user-attachments/assets/d304639d-a46b-4c8a-8263-4e3355c6c867)

---

## 3. Upload Your `swarm.pem` (Optional)

> [!WARNING]
> Skip this if you don’t already have a `swarm.pem` file.  If you do, drag and drop it into the file panel.

![image](https://github.com/user-attachments/assets/94a7bae2-72f8-4e8a-8c6c-5c00c8a5e140)  
![image](https://github.com/user-attachments/assets/77b669a7-5192-4075-8e50-ae109653dc60)

---

## 4. Install Gensyn Node

In the terminal, paste and run:

```bash
curl -s https://quickpod.github.io/gensyn/init.sh | bash
```

![image](https://github.com/user-attachments/assets/80bf41cc-54a8-4106-929a-0b3b1065e355)

Wait until installation is complete.

![image](https://github.com/user-attachments/assets/c39f44c6-1194-4ba3-bf5d-45fc13b52367)

---

## 5. Start the Node

In the terminal, run:

```bash
./run.sh
```

> [!WARNING]
> When prompted to choose between A or B, just press **Enter** unless you know what to pick. Remember your choice for later.

![image](https://github.com/user-attachments/assets/530afc90-efe3-4f19-9745-352729035c6c)  

Just press Enter unless you know about these options.

![image](https://github.com/user-attachments/assets/32f28377-a814-4b91-befc-8192b2e8659b)

If you see a screen like this, continue to Steps 6–7.  
If not, skip to Step 8.

![image](https://github.com/user-attachments/assets/cf7b3eb8-a4aa-442d-9d2c-2c3bc66e0452)

---

## 6. Open the Login Page

Click your **port 3000** link. It will open a new browser tab.

![image](https://github.com/user-attachments/assets/f6e39f1d-fd4b-4dc5-909d-82c80e597e0c)

---

## 7. Authenticate

> [!NOTE]
>  It may take 1–3 minutes. Just wait until you see this.

1. Click on Login
   ![image](https://github.com/user-attachments/assets/c90a5e45-c1f3-439d-bfe2-80202d49f8d9)
   
3. Enter your email address  
   ![image](https://github.com/user-attachments/assets/f43ef0c7-a743-4dd3-822d-ab172598e460)

4. Enter the token sent to your inbox  
   ![image](https://github.com/user-attachments/assets/201b4424-9f74-4c9a-820f-5894aee9a579)  
   ![image](https://github.com/user-attachments/assets/b32e9b6d-3dfe-472d-9787-639fec3f88c9)

5. You should see **Login Success**

   ![image](https://github.com/user-attachments/assets/52e7ef0f-7ef0-4ae4-9763-89470159bf8a)

---

## 8. Check Your Node

> [!WARNING]
> Note you may need to do `step #5` multiple times until you don't get error. of `Daemon failed to start in 15.0 seconds` , gensyn is quite unstable right now. I usually need to try 5 to 10 times on a bad day

![image](https://github.com/user-attachments/assets/d1a53ccc-8875-4691-a2c8-2e93591ec220)


Back in JupyterLab, locate your **ORG ID** and **Peer ID**.

![image](https://github.com/user-attachments/assets/73251815-5d41-4d5b-b810-9f1892542bdc)

Go to: [https://quickpod.github.io/gensyn](https://quickpod.github.io/gensyn)  
Paste your **Peer ID**, and select **A or B** (based on Step 5).

> [!NOTE]
> Gensyn now uses a new swarm system (A/B). Old swarms are deprecated. New swarms will show 0 wins at start

![image](https://github.com/user-attachments/assets/2569b712-0304-4833-8a0c-8af11ac6b7e8)

Example of old swarm (not recommended anymore):

![image](https://github.com/user-attachments/assets/742ecf75-3586-4680-bcb2-b379825dc25a)

---

## 9. Backup Your Identity

> [!WARNING]
> Save `swarm.pem` locally to reconnect later with the same identity.

1. Right-click `swarm.pem`  
2. Click **Download**

![image](https://github.com/user-attachments/assets/8f016d37-980b-4145-8872-4ae9d44db83f)

---
> [!NOTE]
> Your node will stay running even if you close the browser.  To check on it later, just reconnect to JupyterLab.

