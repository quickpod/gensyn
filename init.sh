#!/bin/bash

# Check if we are in /workspace directory
if [ "$PWD" != "/workspace" ]; then
  echo -e "\033[0;31m[✗] Please switch to the /workspace directory before running this script.\033[0m"
  echo -e "\033[1mType: cd /workspace\033[0m"
  exit 1
fi

# Gensyn RL-Swarm node local installation automation script with identity management
# Updated for GenRL-Swarm v0.5.1 architecture

# Configuration variables - modify these as needed
GENRL_SWARM_TAG="v0.5.3"  # GenRL-Swarm repository tag to clone
SWARM_CONTRACT="0xFaD7C5e93f28257429569B854151A1B8DCD404c2"  # Current swarm contract
TAG_VERSION="v0.1.4"  # RL-Swarm repository tag to clone

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
  printf "${YELLOW}GenRL-Swarm ${GENRL_SWARM_TAG} - Reasoning Gym Edition${NC}\n\n"
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

  # Configuration variables for installation
  GENSYN_RESET_CONFIG=${GENSYN_RESET_CONFIG:-""}
  CPU_ONLY=${CPU_ONLY:-""}

  printf "${YELLOW}Cloning Gensyn RL-Swarm repository...${NC}\n"
  if [ -d "genrl" ]; then
    if [ -d "genrl/.git" ]; then
      printf "${YELLOW}Directory 'genrl' is a git repository. Cleaning and pulling latest changes...${NC}\n"
      cd genrl
      git clean -fxd
      git fetch --tags
      git checkout "$TAG_VERSION"
      git pull origin "$TAG_VERSION"
      cd ..
    else
      printf "${YELLOW}Directory 'genrl' already exists but is not a git repository. Skipping clone.${NC}\n"
    fi
  else
    git clone --depth=1 --branch "$TAG_VERSION" https://github.com/gensyn-ai/genrl
  fi

  cd genrl || { printf "${RED}[✗] Failed to change directory to genrl.${NC}\n"; exit 1; }

  # Clone GenRL-Swarm repository
  printf "${YELLOW}Cloning GenRL-Swarm repository...${NC}\n"
  if [ ! -d "rl-swarm" ]; then
    git clone --depth=1 --branch "$GENRL_SWARM_TAG" https://github.com/gensyn-ai/rl-swarm.git rl-swarm
  else
    # Check if we are on the correct tag
    cd rl-swarm
    CURRENT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "unknown")
    if [ "$CURRENT_TAG" != "$GENRL_SWARM_TAG" ]; then
      printf "${YELLOW}Updating rl-swarm to tag $GENRL_SWARM_TAG...${NC}\n"
      git fetch --tags
      git checkout "$GENRL_SWARM_TAG"
      git pull origin "$GENRL_SWARM_TAG"
    fi
    cd ..
  fi

  # Install GenRL-Swarm
  printf "${YELLOW}Installing GenRL-Swarm library...${NC}\n"
  if [ -d "rl-swarm" ]; then
    cd rl-swarm
    
    # Upgrade pip first to avoid conflicts later
    printf "${YELLOW}Upgrading pip...${NC}\n"
    pip3 install --upgrade pip
    
    cd ..
    printf "${GREEN}[✓] GenRL-Swarm directory ready for installation${NC}\n"
  else
    printf "${RED}[✗] rl-swarm directory not found. Unable to install GenRL.${NC}\n"
    exit 1
  fi

  # Patch DHT startup timeout
  printf "${YELLOW}Patching DHT startup timeout...${NC}\n"
  
  # Patch web API DHT timeout
  WEB_DHT_FILE="web/api/global_dht.py"
  if [ -f "$WEB_DHT_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS version
      sed -i '' 's/startup_timeout=60,/startup_timeout=120,/' "$WEB_DHT_FILE"
    else
      # Linux version
      sed -i 's/startup_timeout=60,/startup_timeout=120,/' "$WEB_DHT_FILE"
    fi
    printf "${GREEN}[✓] Web API DHT startup timeout increased to 120 seconds${NC}\n"
  else
    printf "${YELLOW}[!] Web API DHT file not found, skipping web DHT timeout patch${NC}\n"
  fi
  
  # Patch GenRL-Swarm DHT timeout
  printf "${YELLOW}[!] GenRL-Swarm DHT timeout patching temporarily disabled to avoid daemon startup issues${NC}\n"
  # GENRL_DHT_FILE="rl-swarm/src/genrl_swarm/communication/hivemind/hivemind_backend.py"
  # if [ -f "$GENRL_DHT_FILE" ]; then
  #   # Add startup_timeout to both DHT initializations
  #   if [[ "$OSTYPE" == "darwin"* ]]; then
  #     # macOS version
  #     sed -i '' 's/start=True,/start=True,\
  #               startup_timeout=120,/' "$GENRL_DHT_FILE"
  #   else
  #     # Linux version
  #     sed -i 's/start=True,/start=True,\
  #               startup_timeout=120,/' "$GENRL_DHT_FILE"
  #   fi
  #   printf "${GREEN}[✓] GenRL-Swarm DHT startup timeout increased to 120 seconds${NC}\n"
  # else
  #   printf "${YELLOW}[!] GenRL-Swarm DHT file not found, skipping GenRL DHT timeout patch${NC}\n"
  # fi

  # Patch model saving to disable persistence
  printf "${YELLOW}Patching model saving to disable persistence...${NC}\n"
  
  # Patch rgym trainer save method
  RGYM_TRAINER_FILE="rl-swarm/src/genrl_swarm/examples/rgym/trainer.py"
  if [ -f "$RGYM_TRAINER_FILE" ]; then
    # Linux version - disable model saving
    sed -i '/def save(self, save_dir: str) -> None:/,/^    def / {
      /def save(self, save_dir: str) -> None:/!{
        /^    def /!d
      }
    }' "$RGYM_TRAINER_FILE"
    sed -i '/def save(self, save_dir: str) -> None:/a\
      """Save method disabled - no model persistence needed for swarm participation."""\
      pass' "$RGYM_TRAINER_FILE"
    printf "${GREEN}[✓] RGYM trainer model saving disabled${NC}\n"
  fi

  # Setup configuration directory and copy default config
  printf "${YELLOW}Setting up configuration...${NC}\n"
  if [ ! -d "configs" ]; then
    mkdir configs
  fi
  
  if [ -f "configs/rg-swarm.yaml" ]; then
    # Use cmp -s for a silent comparison. If different, backup and copy.
    if ! cmp -s "rl-swarm/rgym_exp/config/rg-swarm.yaml" "configs/rg-swarm.yaml"; then
      printf "${YELLOW}Found differences in rg-swarm.yaml. Backing up existing config...${NC}\n"
      mv "configs/rg-swarm.yaml" "configs/rg-swarm.yaml.bak"
      cp "rl-swarm/rgym_exp/config/rg-swarm.yaml" "configs/rg-swarm.yaml"
    fi
  else
    # If the config doesn't exist, just copy it.
    cp "rl-swarm/rgym_exp/config/rg-swarm.yaml" "configs/rg-swarm.yaml"
  fi
  printf "${GREEN}[✓] Configuration setup complete${NC}\n"

  # Patch modal-login/config.ts to allow only email login
  printf "${YELLOW}Patching modal-login/config.ts to allow only email login...${NC}\n"
  MODAL_CONFIG_FILE="rl-swarm/modal-login/config.ts"
  if [ -f "$MODAL_CONFIG_FILE" ]; then
    # Create a completely new config.ts that fixes the hydration issue
    cat > "$MODAL_CONFIG_FILE" << 'CONFIG_EOF'
import {
  AlchemyAccountsUIConfig,
  cookieStorage,
  createConfig,
} from "@account-kit/react";
import { alchemy, sepolia } from "@account-kit/infra";
import { QueryClient } from "@tanstack/react-query";

const uiConfig: AlchemyAccountsUIConfig = {
  illustrationStyle: "outline",
  auth: {
    sections: [
      [{ type: "email" }],
    ],
    addPasskeyOnSignup: false,
  },
};

export const config = createConfig(
  {
    transport: alchemy({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_API_KEY! }),
    chain: sepolia,
    ssr: true,
    storage: cookieStorage,
    enablePopupOauth: false,
    sessionConfig: {
      expirationTimeMs: 1000 * 60 * 60 * 24 * 30, // 30 days
    },
  },
  uiConfig,
);

export const queryClient = new QueryClient();
CONFIG_EOF
    printf "${GREEN}[✓] Successfully patched modal-login/config.ts to allow only email login and fix hydration${NC}\n"
  else
    printf "${RED}[✗] Could not find $MODAL_CONFIG_FILE for patching. Skipping.${NC}\n"
  fi

  # Check if modal-login directory exists and setup
  if [ ! -d "rl-swarm/modal-login" ]; then
    printf "${RED}[✗] modal-login directory not found. Unable to complete setup.${NC}\n"
    printf "${YELLOW}Make sure you have the correct genrl repository with modal-login support.${NC}\n"
    cd ..
    exit 1
  else
    printf "${YELLOW}Installing Node.js dependencies for modal-login...${NC}\n"
    cd rl-swarm/modal-login
    
    # Install yarn if not available
    if ! command -v yarn > /dev/null 2>&1; then
      npm install -g yarn
    fi
    
    yarn install --immutable
    
    # Build the server during setup
    printf "${YELLOW}Building modal-login server...${NC}\n"
    yarn build
    printf "${GREEN}[✓] modal-login server built${NC}\n"
    
    # Create temp-data directory if it doesn't exist
    mkdir -p temp-data
    cd ../..
    printf "${GREEN}[✓] modal-login dependencies installed and built${NC}\n"
  fi

  cd ..

  printf "${YELLOW}Creating run script (run.sh)...${NC}\n"
  cat > run.sh << 'EOL'
#!/bin/bash

# RL-Swarm execution script with GenRL-Swarm v0.5.1

set -euo pipefail

ROOT=$PWD

export IDENTITY_PATH
export CONNECT_TO_TESTNET=true
export ORG_ID
export HF_HUB_DOWNLOAD_TIMEOUT=120  # 2 minutes
export SWARM_CONTRACT="0xFaD7C5e93f28257429569B854151A1B8DCD404c2"
export HUGGINGFACE_ACCESS_TOKEN="None"

# Path to an RSA private key. If this path does not exist, a new key pair will be created.
DEFAULT_IDENTITY_PATH="$ROOT"/swarm.pem
IDENTITY_PATH=${IDENTITY_PATH:-$DEFAULT_IDENTITY_PATH}

ORG_ID=${ORG_ID:-""}

GREEN_TEXT="\033[32m"
BLUE_TEXT="\033[34m"
RED_TEXT="\033[31m"
RESET_TEXT="\033[0m"

echo_green() {
    echo -e "$GREEN_TEXT$1$RESET_TEXT"
}

echo_blue() {
    echo -e "$BLUE_TEXT$1$RESET_TEXT"
}

echo_red() {
    echo -e "$RED_TEXT$1$RESET_TEXT"
}

ROOT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

# Function to clean up the server process upon exit
cleanup() {
    echo_green ">> Shutting down trainer..."

    # Remove modal credentials if they exist
    rm -r $ROOT_DIR/genrl/rl-swarm/modal-login/temp-data/*.json 2> /dev/null || true

    # Kill all processes belonging to this script's process group
    kill -- -$$ || true

    exit 0
}

errnotify() {
    echo_red ">> An error was detected while running rl-swarm. See $ROOT/genrl/logs for full logs."
}

trap cleanup EXIT
trap errnotify ERR

if [ -d "genrl" ]; then
    cd genrl
else
    echo "Error: genrl directory not found. Please run init.sh first."
    exit 1
fi

echo -e "\033[38;5;224m"
cat << "EOF"
    ██████  ██            ███████ ██     ██  █████  ██████  ███    ███
    ██   ██ ██            ██      ██     ██ ██   ██ ██   ██ ████  ████
    ██████  ██      █████ ███████ ██  █  ██ ███████ ██████  ██ ████ ██
    ██   ██ ██                 ██ ██ ███ ██ ██   ██ ██   ██ ██  ██  ██
    ██   ██ ███████       ███████  ███ ███  ██   ██ ██   ██ ██      ██

    From Gensyn

EOF

# Create logs directory if it doesn't exist
mkdir -p "$ROOT/logs"

# Verify installation was completed
if [ ! -d "rl-swarm" ]; then
    echo_red "Error: GenRL-Swarm not found. Please run init.sh first."
    exit 1
fi

if [ ! -f "configs/rg-swarm.yaml" ]; then
    echo_red "Error: Configuration not found. Please run init.sh first."
    exit 1
fi

if [ "$CONNECT_TO_TESTNET" = true ]; then
    # Run modal_login server.
    echo "Please login to create an Ethereum Server Wallet"
    cd rl-swarm/modal-login

    # Load NVM and Node.js
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use 20.18.0

    # Update contract address in .env file
    ENV_FILE="$ROOT/genrl/rl-swarm/modal-login/.env"
    if [ -f "$ENV_FILE" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS version
            sed -i '' "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
        else
            # Linux version
            sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
        fi
    fi

    # Start the modal login server
    yarn start >> "$ROOT/logs/yarn.log" 2>&1 &
    SERVER_PID=$!
    echo "Started server process: $SERVER_PID"
    sleep 5

    # Try to open the URL in the default browser
    if open http://localhost:3000 2> /dev/null; then
        echo_green ">> Successfully opened http://localhost:3000 in your default browser."
    else
        echo ">> Failed to open http://localhost:3000. Please open it manually."
    fi

    cd ../..

    echo_green ">> Waiting for modal userData.json to be created..."
    while [ ! -f "rl-swarm/modal-login/temp-data/userData.json" ]; do
        sleep 5
    done
    echo "Found userData.json. Proceeding..."

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' rl-swarm/modal-login/temp-data/userData.json)
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

echo_green ">> Hugging Face Hub uploads disabled (models will not be pushed)"

# Check if model name was provided as argument
if [ $# -gt 0 ]; then
    MODEL_NAME="$1"
    export MODEL_NAME
    echo_green ">> Using model: $MODEL_NAME"
else
    echo_green ">> Using default model from config"
fi

echo_green ">> Good luck in the swarm!"
echo_blue ">> And remember to star the repo on GitHub! --> https://github.com/gensyn-ai/rl-swarm"

# Launch the GenRL-Swarm runner
cd rl-swarm
python -m rgym_exp.runner.swarm_launcher \
    --config-path "$ROOT/genrl/rl-swarm/rgym_exp/config" \
    --config-name "rg-swarm.yaml"

wait  # Keep script running until Ctrl+C
EOL

  chmod +x run.sh

  printf "${GREEN}[✓] Run script created${NC}\n"
  printf "${GREEN}[✓] Local installation preparation complete${NC}\n"

  # Install GenRL-Swarm library after all patches are applied
  printf "${YELLOW}Installing GenRL-Swarm library (final step)...${NC}\n"
  if [ -d "genrl" ]; then
    cd genrl
    pip3 install -e .[examples]
    cd ..
    printf "${GREEN}[✓] GenRL-Swarm library installed successfully${NC}\n"
  else
    printf "${RED}[✗] GenRL directory not found at genrl${NC}\n"
    exit 1
  fi

  # Reinstall hivemind to ensure clean p2pd binary
  printf "${YELLOW}Reinstalling hivemind to ensure clean p2pd binary...${NC}\n"
  pip3 install --force-reinstall hivemind
  printf "${GREEN}[✓] Hivemind reinstalled successfully${NC}\n"

  # Patch hivemind p2p_daemon.py startup timeout
  printf "${YELLOW}Patching hivemind p2p_daemon startup timeout...${NC}\n"
  printf "${YELLOW}[!] Hivemind p2p_daemon patching temporarily disabled to avoid startup issues${NC}\n"
  # HIVEMIND_P2P_FILE="/usr/local/lib/python3.10/dist-packages/hivemind/p2p/p2p_daemon.py"
  # if [ -f "$HIVEMIND_P2P_FILE" ]; then
  #   sed -i 's/startup_timeout: float = *15/startup_timeout: float = 120/' "$HIVEMIND_P2P_FILE"
  #   printf "${GREEN}[✓] Hivemind p2p_daemon startup timeout increased to 120 seconds${NC}\n"
  # else
  #   printf "${YELLOW}[!] Hivemind p2p_daemon file not found at $HIVEMIND_P2P_FILE, skipping patch${NC}\n"
  # fi
}

main() {
  print_logo
  install_node
  install_local

  printf "\n${YELLOW}To run RL-Swarm with GenRL-Swarm ${TAG_VERSION}:${NC}\n"
  printf "   ${BOLD}./run.sh${NC}\n\n"

  printf "${YELLOW}Important Notes:${NC}\n"
  printf "• This version uses the new GenRL-Swarm architecture\n"
  printf "• Models are auto-assigned based on your hardware capabilities\n" 
  printf "• The system uses reasoning-gym tasks instead of math problems\n"
  printf "• Configuration is simplified with a single rg-swarm.yaml file\n\n"

  printf "${YELLOW}If you encounter issues, please refer to the official Gensyn Github: https://github.com/gensyn-ai/rl-swarm${NC}\n"
}

main "$@"
