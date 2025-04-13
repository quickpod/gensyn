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
  printf '  ██████╗  ███████╗ ███╗   ██╗ ███████╗ ██╗   ██╗ ███╗   ██╗\n'
  printf ' ██╔════╝  ██╔════╝ ████╗  ██║ ██╔════╝ ╚██╗ ██╔╝ ████╗  ██║\n'
  printf ' ██║  ███╗ ███████╗ ██╔██╗ ██║ ███████╗  ╚████╔╝  ██╔██╗ ██║\n'
  printf ' ██║   ██║ ██╔════╝ ██║╚██╗██║ ╚════██║   ╚██╔╝   ██║╚██╗██║\n'
  printf ' ╚██████╔╝ ███████║ ██║ ╚████║ ███████║    ██║    ██║ ╚████║\n'
  printf '  ╚═════╝  ╚══════╝ ╚═╝  ╚═══╝ ╚══════╝    ╚═╝    ╚═╝  ╚═══╝\n'
  printf "${NC}\n\n"
  printf "${BOLD}RL-Swarm Node Local Installation with Identity Management${NC}\n\n"
}

# Function to install NVM and Node.js v18.17.0 or higher
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
  
  # Install Node.js v18.17.0 or higher
  printf "${YELLOW}Installing Node.js v18.17.0 or higher...${NC}\n"
  nvm install 18
  nvm use 18
  printf "${GREEN}[✓] Node.js $(node -v) installed and set as default${NC}\n"
}

# Function to install dependencies (from original gensyn.sh)
install_dependencies() {
  printf "\n${BLUE}${BOLD}[2/3] Setting up dependency packages...${NC}\n"

  printf "${YELLOW}Note: Running without sudo privileges. Using alternative installation methods.${NC}\n"
  printf "${YELLOW}Installing Python dependencies...${NC}\n"
  
  if ! command -v pip3 &> /dev/null; then
    printf "${YELLOW}Warning: pip3 is not installed. Some features may not work properly.${NC}\n"
  else
    printf "${YELLOW}Installing essential Python packages...${NC}\n"
    pip3 install cryptography
    printf "${GREEN}[✓] Installed cryptography library for identity management${NC}\n"

    printf "${YELLOW}Installing required Python packages with version constraints...${NC}\n"
    pip3 install "eth-account>=0.8.0,<0.13.0" "web3<7.0.0" "pydantic<2.0" "numpy<2.0" "protobuf>=4.21.0" "hivemind"
    printf "${GREEN}[✓] Installed eth-account, web3, pydantic, numpy, protobuf, and hivemind with version constraints${NC}\n"

    printf "${YELLOW}Installing PyTorch and torchvision with CUDA ${CUDA_VERSION}...${NC}\n"
    pip3 install torch==2.2.2 torchvision --index-url https://download.pytorch.org/whl/${CUDA_VERSION}
    printf "${GREEN}[✓] Installed PyTorch 2.2.2 and torchvision with CUDA ${CUDA_VERSION}${NC}\n"
  fi

  for cmd in curl git python3 python3-pip; do
    if ! command -v $cmd &> /dev/null; then
      printf "${YELLOW}Warning: $cmd is not installed. Some features may not work properly.${NC}\n"
      printf "${YELLOW}Recommendation: Install $cmd using your system's package manager.${NC}\n"
    fi
  done

  printf "${GREEN}[✓] Base dependency installation complete${NC}\n"
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

  printf "${YELLOW}Installing Python dependencies globally...${NC}\n"

  if [ -f "requirements.txt" ]; then
    printf "${YELLOW}Installing Python dependencies from requirements.txt...${NC}\n"
    pip3 install -r requirements.txt
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

CONNECT_TO_TESTNET="True"
echo "Will connect to Testnet: $CONNECT_TO_TESTNET"

# Load NVM and Node.js v18 or higher
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm use 18

# Always start modal_login server
cd modal-login
echo "Starting modal-login server on port 3000..."
npm run dev --legacy-peer-deps > /dev/null 2>&1 &
SERVER_PID=$!  # Store the process ID
sleep 5

echo -e "${GREEN}===========================================================${NC}"
echo -e "${YELLOW}Modal login server is now running on port 3000${NC}"
echo -e "${YELLOW}Access via your pod's URL if you need to create/update credentials.${NC}"
echo -e "${YELLOW}If using Chrome, you may need to enable Web Crypto API:${NC}"
echo -e "${GREEN}1.${NC} Go to chrome://flags/#unsafely-treat-insecure-origin-as-secure"
echo -e "${GREEN}2.${NC} Add your pod's URL to treat as secure"
echo -e "${GREEN}3.${NC} Relaunch Chrome and visit your pod's URL"
echo -e "${GREEN}4.${NC} Verify by typing 'crypto.subtle' in the DevTools Console"
echo -e "${GREEN}===========================================================${NC}"

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

if [ -z "$CONFIG_PATH" ]; then
    if command -v nvidia-smi &> /dev/null || [ -d "/proc/driver/nvidia" ]; then
        echo "GPU detected, using GPU configuration"
        CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml"
    else
        echo "No GPU detected, using CPU configuration"
        CONFIG_PATH="$ROOT/hivemind_exp/configs/cpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml"
    fi
fi

echo "Using config: $CONFIG_PATH"

python -m hivemind_exp.gsm8k.train_single_gpu \
    --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
    --identity_path "$IDENTITY_PATH" \
    --modal_org_id "$ORG_ID" \
    --config "$CONFIG_PATH"

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
  install_dependencies
  install_local

  printf "\n${YELLOW}To run RL-Swarm with modal login:${NC}\n"
  printf "   ${BOLD}./run.sh${NC}\n\n"
  
  printf "${YELLOW}Note on Web Crypto API for Chrome:${NC}\n"
  printf "   ${BOLD}1. Go to chrome://flags/#unsafely-treat-insecure-origin-as-secure${NC}\n"
  printf "   ${BOLD}2. Add your pod's URL to treat as secure${NC}\n"
  printf "   ${BOLD}3. Relaunch Chrome and access your pod's URL${NC}\n"
  printf "   ${BOLD}4. Verify by typing 'crypto.subtle' in DevTools Console${NC}\n\n"

  printf "${GREEN}${BOLD}Gensyn RL-Swarm local installation with identity management finished!${NC}\n"
  printf "${YELLOW}If you encounter issues, please refer to the official Gensyn Github: https://github.com/gensyn-ai/rl-swarm${NC}\n"
}

main "$@"
