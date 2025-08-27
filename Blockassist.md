# Gensyn Blockassist Guide
> [!Note]
> This guide assumes you have already set up a Huggingface account and have created an access token with Write Access. Please see https://github.com/gensyn-ai/blockassist for more details about the project.

## 1. Getting Started
1. Navigate to the [Templates page](https://console.quickpod.io/templates) on the QuickPod console.
2. Find the Ubuntu 24.04 Desktop Kasm template, then hit Select.
   - (Optional) If you wish to change the default password for security purposes, instead clone the template and modify the corresponding environment variable.
   <img width="1562" height="707" alt="image" src="https://github.com/user-attachments/assets/a3836a99-51bf-4393-ac4e-2b839e709f0d" />
3. Find a suitable GPU pod. We recommend at least a 3060 for stable performance.
> [!Warning]
> Low-end GPUs will experience poor performance in both playing Minecraft and encoding the video stream.
> [!Note]
> Try to find a machine as close to your physical geolocation as possible. This will greatly affect latency and perceived perfomance on the machine.

4. Create your pod with at least 50GB of storage. It may take up to 5 minutes for the pod to initialize.

## 2. Installing and Configuring Blockassist
1. Click the **Connect** button under your pod, then click the port mapped to 4000.
   <img width="1005" height="538" alt="Connect Box" src="https://github.com/user-attachments/assets/9e9b1282-2239-423e-8dc3-ead575bb2b28" />
> [!Important]
> If the page fails to load, try forcing SSL by adding **https://** in front of the address in the browser
> <img width="1638" height="1592" alt="image" src="https://github.com/user-attachments/assets/197c66f3-2857-47cb-884e-0a18bddc07ae" />

2. You will be presented with a login dialog box. Unless you set custom credentials, the login is "quickpod"/"abcd1234".
3. Once the desktop loads, find the terminal application. It is usually found at the toolbar at the bottom of the screen.
   <img width="3777" height="2000" alt="image" src="https://github.com/user-attachments/assets/037aa308-9c06-41bc-8155-93d200ce9e11" />
4. Paste the following command into the terminal and run it.
   `git clone https://github.com/gensyn-ai/blockassist.git && cd blockassist && ./setup.sh && curl -fsSL https://pyenv.run | bash`
> [!Important]
> If prompted, enter the same password that you used to access the VNC viewer to authenticate the terminal.
> [!Note]
> If you can't paste from your local clipboard, check your browser settings and enable permission for the Kasm webpage to access the clipboard.
> <img width="587" height="566" alt="image" src="https://github.com/user-attachments/assets/c49e04f8-39aa-44af-9405-52fc6e6137ff" />

5.  Paste the following commands, then **exit and open the terminal again**.
```
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
```
6. Paste the following commands, then execute. If prompted for a password, enter the same one again from before.
```
sudo apt update
sudo apt install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
pyenv install 3.10
cd ~/blockassist
python -m pip install --break-system-packages psutil readchar
```
## 3. Play Minecraft!
1. Run `python run.py` to begin loading Blockassist.
2. It should prompt you for your Huggingface token. Please see https://huggingface.co/docs/hub/en/security-tokens for more information about generating a token if you do not yet have one.
3. After it validates your token, it will begin downloading dependencies. Depending on the internet speed of the pod, this may take a while.
4. Eventually, you will be promoted to login. It will automatically open the web browser to the authentication page
> [!Important]
> Some pods may have a different networking configuration where localhost will not work! If this is the case, go to `127.0.0.1:3000` instead to finish authenticating. It may take 30 seconds-1 minute to load.
5.  Once you are logged in, follow the instructions in the terminal to begin playing!

## 4. FAQ
- My game is lagging and it's hard to play!
  - This is dependent on many factors. However, the most common issue is latency between your PC and the host pod. Try selecing a machine geographically closer to you, if possible.
- How can I improve my FPS in Minecraft?
  - Select a pod with a strong _consumer-grade CPU_ and decent GPU. Although Xeon and EPYC processors are powerful, they often have slow single-core clock speeds, which Minecraft relies heavily on. Consumer-grade processors often have faster single-core clocks.
  - Lower the resolution of your window. This can be done by selecting the Control Bar at the left side of your screen and going to Settings > Stream Quality.
- My mouse is glitching or moving by Minecraft view in random directions!
  - Try enabling Game Cursor Mode in the Control Bar of Kasm. This will prevent your cursor from moving "off-screen" and messing up the viewport.
- My local PC's performance seems really low. Is there any way to improve it?
  - Try lowering the resolution of the Kasm webpage though the Control Bar > Settings > Stream Quality
  - If you have a weak CPU, you can also lower or disable compression through Control Bar > Settings > Advanced. Lower compression will require faster internet to retain a playable experience.
