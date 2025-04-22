# Quick Start Guide — Gensyn RL-Swarm on QuickPod

---

## 1. Create Your Pod

1. Go to [QuickPod Templates](https://console.quickpod.io/templates)
2. Select `Jupyter Lab CUDA 12.6`, clone it and name anything you like. Example `Gensyn 12.6`
   
   ![image](https://github.com/user-attachments/assets/bb3b85bf-9eee-41d3-95a5-40d8fbc95878)
   
   Set `-p 3000:3000 --shm-size=16g` then press `Save` below this window
   
   ![msedge_uOQO96e36Z](https://github.com/user-attachments/assets/3c9aa89e-33e2-4b92-a92e-d2e15ea09679)


4. Choose a GPU:
   - 3090 / 4090 / A5000
   > You can also choose CPU, you can try at least 4 cores
     
   Choose your the template you created on step 2
   
   ![image](https://github.com/user-attachments/assets/31ab3b50-1908-4425-b660-7072eb936b64)

6. Click the orange button `Connect to JupyterLab`

   ![image](https://github.com/user-attachments/assets/e797c4c3-f8ec-4b43-8ae2-72b29dc13561)

---

## 2. Open Terminal

1. Once inside JupyterLab, click `Terminal` on the left panel.

   ![image](https://github.com/user-attachments/assets/d304639d-a46b-4c8a-8263-4e3355c6c867)

---

## 3. Upload Your `swarm.pem` (Optional)

> [!WARNING]
> Skip this if you don’t have a `swarm.pem` file.  
> 
> If you’ve never logged in to Gensyn via Alchemy before, your existing `swarm.pem` (if any) won’t work — just create a new one by following the steps below.  
> 
> Otherwise, feel free to reuse your existing `swarm.pem` file.

1. Drag and drop your `swarm.pem` file to the left panel.

   ![image](https://github.com/user-attachments/assets/94a7bae2-72f8-4e8a-8c6c-5c00c8a5e140)

   ![image](https://github.com/user-attachments/assets/77b669a7-5192-4075-8e50-ae109653dc60)

---

## 4. Install Gensyn Node

In the terminal, run:

```bash
curl -s https://quickpod.github.io/gensyn/init.sh | bash
```

   ![image](https://github.com/user-attachments/assets/80bf41cc-54a8-4106-929a-0b3b1065e355)

Wait for the setup to finish.

   ![image](https://github.com/user-attachments/assets/33baf4d5-ea54-4ca4-9d33-1e625357d2d8)


---


## 5. Run the Node

> [!NOTE]
> If you've already logged in to Gensyn via Alchemy before (and have a working `swarm.pem`), this will automatically skip steps 6 and 7

Start Gensyn Node:

```bash
./run.sh
```

   ![image](https://github.com/user-attachments/assets/731d1dc8-0e94-46b2-b62b-de3d33f19c2f)

---

## 6. Login to Gensyn

1. Copy the URL of `port 3000` shown in the terminal.

   ![image](https://github.com/user-attachments/assets/5daed881-18c7-475d-b6ed-0261922c2f31)

2. Open it in Chrome or Edge.
   Go to:  `chrome://flags/#allow-insecure-localhost`  
   Enable it and restart the browser.

   ![image](https://github.com/user-attachments/assets/4a69e555-8c66-410b-babf-bfb09861ff4c)

3. Click `Restart` — it should show below:

   ![image](https://github.com/user-attachments/assets/c5cce846-ebbe-41d5-a165-1dd8563b1be3)

4. Click your `port 3000` link to open the login page.

   ![image](https://github.com/user-attachments/assets/1cfce446-d821-46b6-9e76-d4d0393c6643)

---

## 7. Authenticate
   Wait until the login screen appears. It will take some time, it will be white page or cannot be reached at first. Just keep on trying for 1 to 3 minutes.

   ![image](https://github.com/user-attachments/assets/01f32c36-21e4-4d3c-9bb3-bbfb23377e58)

1. Enter your email (Do not use Google/Facebook/Passkey)

   ![image](https://github.com/user-attachments/assets/223a12e2-96b7-406e-9e7a-512de7a1a169)

2. Enter the token sent to your email.

   ![image](https://github.com/user-attachments/assets/201b4424-9f74-4c9a-820f-5894aee9a579)

   ![image](https://github.com/user-attachments/assets/b32e9b6d-3dfe-472d-9787-639fec3f88c9)

3. You should see `Login Success`.

   ![image](https://github.com/user-attachments/assets/52e7ef0f-7ef0-4ae4-9763-89470159bf8a)

---

## 8. Verify Node is Running

   Back in JupyterLab:

   ![image](https://github.com/user-attachments/assets/c9c4a68a-1dbf-49f3-a0cd-df35b9d87613)

Go to [https://quickpod.github.io/gensyn](https://quickpod.github.io/gensyn)

   Enter your Peer Key.

   ![image](https://github.com/user-attachments/assets/3c0308a4-e1f8-422d-8774-db05fdd110a3)

Make sure your `EOA` has a value:

   ![image](https://github.com/user-attachments/assets/03b74e76-0032-41ad-ad68-d054d246a6dc)

---

## 9. Backup Your Identity

> [!WARNING]
> Do not forget to backup your `swarm.pem` else you will be unable to connect to the swarm using the same identity.

After everything is working:

1. Right-click on `swarm.pem`
2. Select `Download` to save it locally.

![image](https://github.com/user-attachments/assets/8f016d37-980b-4145-8872-4ae9d44db83f)

---
> [!NOTE]
> You can close the browser tab. Your node will continue running. Next time, just reconnect to JupyterLab to check status.

---
