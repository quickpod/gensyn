#!/bin/bash

# Gensyn RL-Swarm node local installation automation script with identity management
# Extension of the original gensyn.sh script to support identity management with modal login

# Configuration variables - modify these as needed
CUDA_VERSION="cu121"  # CUDA version for PyTorch installation (e.g., cu121, cu126, etc.)

# Text color and formatting definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print the logo
print_logo() {
  printf "${BLUE}${BOLD}"
  printf "\n\n"
  # ASCII Art for RL-SWARM
  printf '██████╗  ██╗            ███████╗ ██╗    ██╗   █████╗   ██████╗  ███╗   ███╗\n'
  printf '██╔══██╗ ██║            ██╔════╝ ██║    ██║  ██╔══██╗  ██╔══██╗ ████╗ ████║\n'
  printf '██████╔╝ ██║      ████  ███████╗ ██║ ██ ██║ ████████║  ██████╔╝ ██╔████╔██║\n'
  printf '██╔══██╗ ██║            ╚════██║ ██║██████║ ██╔═══██║  ██╔══██╗ ██║╚██╔╝██║\n'
  printf '██║  ██║ ███████╗       ███████║ ╚███╔███╔╝ ██║   ██║  ██║  ██║ ██║ ╚═╝ ██║\n'
  printf '╚═╝  ╚═╝ ╚══════╝       ╚══════╝  ╚══╝╚══╝  ╚═╝   ╚═╝  ╚═╝  ╚═╝ ╚═╝     ╚═╝\n'
  # End of ASCII Art
  printf "${NC}\n\n"
}

# Function to install NVM and Node.js v20.18.0 or higher
install_node() {
  printf "\n${BLUE}${BOLD}[1/3] Setting up Node.js environment...${NC}\n"
  
  # Check if NVM is installed
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    printf "${YELLOW}NVM already installed. Loading NVM...${NC}\n"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  else
    printf "${YELLOW}Installing NVM...${NC}\n"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    
    # Load NVM immediately
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  fi
  
  # Install Node.js v20.18.0 or higher
  printf "${YELLOW}Installing Node.js v20.18.0 or higher...${NC}\n"
  nvm install 20.18.0
  nvm use 20.18.0
  printf "${GREEN}[✓] Node.js $(node -v) installed and set as default${NC}\n"
}

install_local() {
  printf "\n${BLUE}${BOLD}[3/3] Installing Gensyn RL-Swarm locally...${NC}\n"

  printf "${YELLOW}Cloning Gensyn RL-Swarm repository...${NC}\n"
  if [ -d "rl-swarm" ]; then
    printf "${YELLOW}Directory 'rl-swarm' already exists. Skipping clone.${NC}\n"
  else
    git clone https://github.com/gensyn-ai/rl-swarm.git
  fi

  cd rl-swarm || { printf "${RED}[✗] Failed to change directory to rl-swarm.${NC}\n"; exit 1; }

  # Patch testnet_grpo_runner.py to add startup_timeout parameter
  printf "${YELLOW}Patching testnet_grpo_runner.py to add DHT startup timeout...${NC}\n"
  RUNNER_FILE="hivemind_exp/runner/gensyn/testnet_grpo_runner.py"
  if [ -f "$RUNNER_FILE" ]; then
    # Use sed to replace the DHT initialization line with the patched version
    sed -i 's/dht = hivemind\.DHT(start=True, \*\*self\._dht_kwargs(grpo_args))/dht = hivemind\.DHT(start=True, startup_timeout=100, \*\*self\._dht_kwargs(grpo_args))/' "$RUNNER_FILE"
    printf "${GREEN}[✓] Successfully patched testnet_grpo_runner.py to add DHT startup timeout${NC}\n"
  else
    printf "${RED}[✗] Could not find $RUNNER_FILE for patching. Skipping.${NC}\n"
  fi

  # Patch hivemind_grpo_trainer.py to remove only .save_model and .save_pretrained calls
  printf "${YELLOW}Patching hivemind_grpo_trainer.py to remove .save_model and .save_pretrained calls...${NC}\n"
  TRAINER_FILE="hivemind_exp/trainer/hivemind_grpo_trainer.py"
  if [ -f "$TRAINER_FILE" ]; then
    sed -i '/\.save_model/d' "$TRAINER_FILE"
    sed -i '/\.save_pretrained/d' "$TRAINER_FILE"
    printf "${GREEN}[✓] Successfully patched hivemind_grpo_trainer.py to remove .save_model and .save_pretrained calls${NC}\n"
  else
    printf "${RED}[✗] Could not find $TRAINER_FILE for patching. Skipping.${NC}\n"
  fi

  # Patch modal-login/config.ts to allow only email login
  printf "${YELLOW}Patching modal-login/config.ts to allow only email login...${NC}\n"
  MODAL_CONFIG_FILE="modal-login/config.ts"
  if [ -f "$MODAL_CONFIG_FILE" ]; then
    awk '/const uiConfig: AlchemyAccountsUIConfig = {/{flag=1; print "const uiConfig: AlchemyAccountsUIConfig = {\n  illustrationStyle: \"outline\",\n  auth: {\n    sections: [\n      [{ type: \"email\" }],\n    ],\n    addPasskeyOnSignup: false,\n    //header: <img src=\"logo.png\"/>,\n  },\n};"; next} /};/ && flag{flag=0; next} !flag' "$MODAL_CONFIG_FILE" > "$MODAL_CONFIG_FILE.tmp" && mv "$MODAL_CONFIG_FILE.tmp" "$MODAL_CONFIG_FILE"
    printf "${GREEN}[✓] Successfully patched modal-login/config.ts to allow only email login${NC}\n"
  else
    printf "${RED}[✗] Could not find $MODAL_CONFIG_FILE for patching. Skipping.${NC}\n"
  fi

  printf "${YELLOW}Installing Python dependencies globally...${NC}\n"
  pip3 install --upgrade pip

  if [ -f "requirements-gpu.txt" ]; then
    printf "${YELLOW}Installing Python dependencies from requirements-gpu.txt...${NC}\n"
    pip3 install -r requirements-gpu.txt
    printf "${GREEN}[✓] Python dependencies installed globally${NC}\n"
  else
    printf "${RED}[✗] requirements.txt not found. Unable to install Python dependencies.${NC}\n"
  fi

  if [ -f "requirements-cpu.txt" ]; then
    printf "${YELLOW}Installing Python dependencies from requirements-cpu.txt...${NC}\n"
    pip3 install -r requirements-cpu.txt
    printf "${GREEN}[✓] Python dependencies installed globally${NC}\n"
  else
    printf "${RED}[✗] requirements.txt not found. Unable to install Python dependencies.${NC}\n"
  fi

  # Check if modal-login directory exists and setup
  if [ ! -d "modal-login" ]; then
    printf "${RED}[✗] modal-login directory not found. Unable to complete setup.${NC}\n"
    printf "${YELLOW}Make sure you have the correct rl-swarm repository with modal-login support.${NC}\n"
    cd ..
    exit 1
  else
    printf "${YELLOW}Installing Node.js dependencies for modal-login...${NC}\n"
    cd modal-login
    npm install --legacy-peer-deps
    # Create temp-data directory if it doesn't exist
    mkdir -p temp-data
    cd ..
    printf "${GREEN}[✓] modal-login dependencies installed${NC}\n"
  fi

  cd ..

  printf "${YELLOW}Creating run script (run.sh)...${NC}\n"
  cat > run.sh << 'EOL'
#!/bin/bash

# RL-Swarm execution script with modal login

export PUB_MULTI_ADDRS
export PEER_MULTI_ADDRS
export HOST_MULTI_ADDRS
export IDENTITY_PATH
export CONNECT_TO_TESTNET
export ORG_ID
export HF_HUB_DOWNLOAD_TIMEOUT=120

IDENTITY_PATH="$PWD/swarm.pem"

if [ -d "rl-swarm" ]; then
    cd rl-swarm
else
    echo "Error: rl-swarm directory not found. Please run init.sh first."
    exit 1
fi

ROOT=$PWD

DEFAULT_PUB_MULTI_ADDRS=""
PUB_MULTI_ADDRS=${PUB_MULTI_ADDRS:-$DEFAULT_PUB_MULTI_ADDRS}

DEFAULT_PEER_MULTI_ADDRS="/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ"
PEER_MULTI_ADDRS=${PEER_MULTI_ADDRS:-$DEFAULT_PEER_MULTI_ADDRS}

DEFAULT_HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/38331"
HOST_MULTI_ADDRS=${HOST_MULTI_ADDRS:-$DEFAULT_HOST_MULTI_ADDRS}

# === NEW: Swarm and Config Selection ===
SMALL_SWARM_CONTRACT="0x69C6e1D608ec64885E7b185d39b04B491a71768C"
BIG_SWARM_CONTRACT="0x6947c6E196a48B77eFa9331EC1E3e45f3Ee5Fd58"
OLD_SWARM_CONTRACT="0x2fC68a233EF9E9509f034DD551FF90A79a0B8F82"

# Explanation for user choices
cat <<EOT

==================== RL-Swarm Swarm Selection ====================
You can join one of three swarms:
  [A] Math (GSM8K dataset)      - Standard math problems, suitable for most users.
  [B] Math Hard (DAPO-Math 17K) - Harder math problems, requires more resources.
  [O] Old Swarm                 - Legacy contract, for advanced users or compatibility.

Choose 'A' for the regular Math swarm, 'B' for the Math Hard swarm, or 'O' for the Old Swarm.
==================================================================
EOT

SWARM_DEFAULT="A"

while true; do
    read -p ">> Which swarm would you like to join (Math (A), Math Hard (B), or Old (O))? [A/b/o, default: $SWARM_DEFAULT] " ab
    ab=${ab:-$SWARM_DEFAULT}
    case $ab in
        [Aa]*)  USE_SWARM="A" && break ;;
        [Bb]*)  USE_SWARM="B" && break ;;
        [Oo]*)  USE_SWARM="O" && break ;;
        *)  echo ">>> Please answer A, B, or O." ;;
    esac

done
if [ "$USE_SWARM" = "B" ]; then
    SWARM_CONTRACT="$BIG_SWARM_CONTRACT"
elif [ "$USE_SWARM" = "O" ]; then
    SWARM_CONTRACT="$OLD_SWARM_CONTRACT"
else
    SWARM_CONTRACT="$SMALL_SWARM_CONTRACT"
fi

# Detect VRAM and set recommended default model size
if command -v nvidia-smi &> /dev/null; then
    VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n1)
    if [ "$VRAM" -ge 80000 ]; then
        MODEL_DEFAULT=32
    elif [ "$VRAM" -ge 48000 ]; then
        MODEL_DEFAULT=7
    elif [ "$VRAM" -ge 24000 ]; then
        MODEL_DEFAULT=1.5
    else
        MODEL_DEFAULT=0.5
    fi
    echo "Detected GPU VRAM: ${VRAM}MB. Recommended default model size: ${MODEL_DEFAULT}B"
else
    MODEL_DEFAULT=0.5
    echo "No NVIDIA GPU detected. Defaulting to smallest model size: 0.5B"
fi

# Update SMART_CONTRACT_ADDRESS in modal-login/.env if it exists
ENV_FILE="/workspace/rl-swarm/modal-login/.env"
if [ -f "$ENV_FILE" ]; then
 sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
  printf "${GREEN}[✓] Updated SMART_CONTRACT_ADDRESS in modal-login/.env${NC}\n"
else
  printf "${YELLOW}[!] modal-login/.env not found, skipping SMART_CONTRACT_ADDRESS update${NC}\n"
fi

cat <<EOT

==================== Model Size Selection ========================
Choose the number of model parameters (in billions):
  0.5  - Qwen 2.5 0.5B   (smallest, runs on most CPUs, 16GB+ RAM)
  1.5  - Qwen 2.5 1.5B   (small, runs on most GPUs, 24GB+ VRAM)
  7    - Qwen 2.5 7B     (medium, needs strong GPU, 48GB+ VRAM)
  32   - Qwen 2.5 32B    (large, needs A100/H100 80GB GPU, 4-bit)
  72   - Qwen 2.5 72B    (largest, needs A100/H100 80GB GPU, 4-bit)

Smaller models require less memory and compute, but are less powerful.
Larger models require more resources, but can achieve better results.
==================================================================
EOT

while true; do
    read -p ">> How many parameters (in billions)? [0.5, 1.5, 7, 32, 72] (default: $MODEL_DEFAULT) " pc
    pc=${pc:-$MODEL_DEFAULT}
    case $pc in
        0.5 | 1.5 | 7 | 32 | 72) PARAM_B=$pc && break ;;
        *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
    esac
done

# Set config and game based on choices
if command -v nvidia-smi &> /dev/null || [ -d "/proc/driver/nvidia" ]; then
    # GPU
    case "$PARAM_B" in
        32 | 72) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-bnb-4bit-deepseek-r1.yaml" ;;
        0.5 | 1.5 | 7) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-deepseek-r1.yaml" ;;
    esac
    if [ "$USE_SWARM" = "B" ]; then
        GAME="dapo"
    else
        GAME="gsm8k"
    fi
else
    # CPU
    CONFIG_PATH="$ROOT/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml"
    GAME="gsm8k"
fi
# === END NEW ===

CONNECT_TO_TESTNET="True"
echo "Will connect to Testnet: $CONNECT_TO_TESTNET"

# Load NVM and Node.js v18 or higher
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm use 18

# Always start modal_login server
cd modal-login
pkill -f next-server
echo "Starting modal-login server on port 3000..."
npm run dev --legacy-peer-deps > /dev/null 2>&1 &
SERVER_PID=$!  # Store the process ID
sleep 5

echo -e "${YELLOW}Modal login server is now running on port 3000${NC}"

# Check if credential files already exist
if [ -f "temp-data/userData.json" ] && [ -f "temp-data/userApiKey.json" ]; then
    echo "Found existing login credentials. Using them without waiting for login process."
    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"
else
    echo "No existing credentials found. Please complete the login process in your browser."
    echo "Waiting for modal userData.json to be created..."
    while [ ! -f "temp-data/userData.json" ]; do
        sleep 5  # Wait for 5 seconds before checking again
    done
    echo "Found userData.json. Proceeding..."

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"

    # Wait until the API key is activated by the client
    echo "Waiting for API key to become activated..."
    while true; do
        STATUS=$(curl -s "http://localhost:3000/api/get-api-key-status?orgId=$ORG_ID")
        if [[ "$STATUS" == "activated" ]]; then
            echo "API key is activated! Proceeding..."
            break
        else
            echo "Waiting for API key to be activated..."
            sleep 5
        fi
    done
fi

cd ..

HUGGINGFACE_ACCESS_TOKEN="None"
echo "Good luck in the swarm!"

echo "Using config: $CONFIG_PATH"

# ... after SWARM_CONTRACT is set

CACHE_FILE="/workspace/rl-swarm/modal-login/.last_swarm_choice"
TEMPDATA_DIR="/workspace/rl-swarm/modal-login/temp-data"

# Read previous choice if exists
if [ -f "$CACHE_FILE" ]; then
    LAST_CHOICE=$(cat "$CACHE_FILE")
else
    LAST_CHOICE=""
fi

# If the contract changed, clear temp-data
if [ "$SWARM_CONTRACT" != "$LAST_CHOICE" ]; then
    echo "Swarm contract changed. Clearing cached login data..."
    rm -rf "$TEMPDATA_DIR"/*
fi

# Cache the current contract
echo "$SWARM_CONTRACT" > "$CACHE_FILE"

python -m hivemind_exp.gsm8k.train_single_gpu \
    --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
    --identity_path "$IDENTITY_PATH" \
    --modal_org_id "$ORG_ID" \
    --contract_address "$SWARM_CONTRACT" \
    --config "$CONFIG_PATH" \
    --game "$GAME"

# Clean up only if SERVER_PID exists (login server was started)
if [ ! -z "$SERVER_PID" ]; then
    kill $SERVER_PID
fi

wait
EOL

  chmod +x run.sh

  printf "${GREEN}[✓] Run script created${NC}\n"
  printf "${GREEN}[✓] Local installation preparation complete${NC}\n"
}

main() {
  print_logo
  install_node
  install_local

  printf "\n${YELLOW}To run RL-Swarm with modal login:${NC}\n"
  printf "   ${BOLD}./run.sh${NC}\n\n"

  printf "${YELLOW}If you encounter issues, please refer to the official Gensyn Github: https://github.com/gensyn-ai/rl-swarm${NC}\n"
}

main "$@"
