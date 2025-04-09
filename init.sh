#!/bin/bash

# Gensyn RL-Swarm node local installation automation script with identity management
# Extension of the original gensyn.sh script to support identity management without modal login

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

# Function to install dependencies (from original gensyn.sh)
install_dependencies() {
  printf "\n${BLUE}${BOLD}[1/3] Setting up dependency packages...${NC}\n"

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
  printf "\n${BLUE}${BOLD}[2/3] Installing Gensyn RL-Swarm locally...${NC}\n"

  printf "${YELLOW}Cloning Gensyn RL-Swarm repository...${NC}\n"
  if [ -d "rl-swarm" ]; then
    printf "${YELLOW}Directory 'rl-swarm' already exists. Skipping clone.${NC}\n"
  else
    git clone https://github.com/gensyn-ai/rl-swarm.git
  fi

  cd rl-swarm || { printf "${RED}[✗] Failed to change directory to rl-swarm.${NC}\n"; exit 1; }

  printf "${YELLOW}Installing Python dependencies globally...${NC}\n"

  if [ -f "requirements.txt" ]; then
    printf "${YELLOW}Installing Python dependencies from requirements.txt...${NC}\n"
    pip3 install -r requirements.txt
    printf "${GREEN}[✓] Python dependencies installed globally${NC}\n"
  else
    printf "${RED}[✗] requirements.txt not found. Unable to install Python dependencies.${NC}\n"
  fi

  cd ..

  printf "${YELLOW}Creating run script (run.sh)...${NC}\n"
  cat > run.sh << 'EOL'
#!/bin/bash

# RL-Swarm execution script without modal login for JupyterLab

export PUB_MULTI_ADDRS
export PEER_MULTI_ADDRS
export HOST_MULTI_ADDRS
export IDENTITY_PATH
export CONNECT_TO_TESTNET
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

DEFAULT_PEER_MULTI_ADDRS="/ip4/159.89.214.152/tcp/31337/p2p/QmedTaZXmULqwspJXz44SsPZyTNKxhnnFvYRajfH7MGhCY /ip4/159.203.156.48/tcp/31338/p2p/QmQGTqmM7NKjV6ggU1ZCap8zWiyKR89RViDXiqehSiCpY5"
PEER_MULTI_ADDRS=${PEER_MULTI_ADDRS:-$DEFAULT_PEER_MULTI_ADDRS}

DEFAULT_HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/38331"
HOST_MULTI_ADDRS=${HOST_MULTI_ADDRS:-$DEFAULT_HOST_MULTI_ADDRS}

CONNECT_TO_TESTNET="True"
echo "Will connect to Testnet: $CONNECT_TO_TESTNET"

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
    --public_maddr "$PUB_MULTI_ADDRS" \
    --initial_peers $PEER_MULTI_ADDRS \
    --host_maddr "$HOST_MULTI_ADDRS" \
    --config "$CONFIG_PATH"

wait
EOL

  chmod +x run.sh
  printf "${GREEN}[✓] Run script created${NC}\n"
  printf "${GREEN}[✓] Local installation preparation complete${NC}\n"
}

main() {
  print_logo
  install_dependencies
  install_local

  printf "\n${YELLOW}To run RL-Swarm in JupyterLab console:${NC}\n"
  printf "   ${BOLD}./run.sh${NC}\n\n"

  printf "${GREEN}${BOLD}Gensyn RL-Swarm local installation with identity management finished!${NC}\n"
  printf "${YELLOW}If you encounter issues, please refer to the official Gensyn Github: https://github.com/gensyn-ai/rl-swarm${NC}\n"
}

main "$@"
