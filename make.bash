#!/bin/bash

# Check for prerequisites
if ! command -v pnpm &> /dev/null; then
  echo "Error: pnpm is not installed. Please install it and try again."
  exit 1
fi

# Function to create a Next.js app
init_next_app() {
  local app_name=$1
  mkdir -p "apps/$app_name"
  cd "apps/$app_name"
  echo "Creating Next.js app: $app_name..."
  pnpm dlx create-next-app@latest . --ts --eslint --tailwind --src-dir --app --turbopack --import-alias "@/*" --skip-install
  
  npm pkg set name="@drop-vortex/$app_name"
  echo "Updated package.json name to '@drop-vortex/$app_name'."
  
  echo "Next.js app '$app_name' created successfully."
  cd ../..
}

# Root files & setup
mkdir -p @drop-vortex
cd @drop-vortex
echo -e "node_modules" > .gitignore
echo "#Drop Vortex" > README.md

cat << EOF > pnpm-workspace.yaml
packages:
  - apps/*
  - server/*
  - packages/*
EOF

pnpm init -w
npm pkg set engines.node=">=22.0.0" 
npm pkg set type="module"
npm pkg set packageManager="pnpm@9.14.3"
git init

# List of frontend apps
frontend_apps=("public-frontend" "retailer-frontend" "supplier-frontend")

# Create Next.js apps
for app in "${frontend_apps[@]}"; do
  init_next_app "$app"
done

# Function to create server structure
init_server_structure() {
  echo "Creating server structure..."
  mkdir -p server/src/{controllers,models,routes,services,utils,middlewares,config,tests,migrations}
  touch server/src/{controllers,index.ts,models,index.ts,routes,index.ts,services,index.ts,utils,index.ts,middlewares,index.ts,config,index.ts,tests,index.ts,migrations,index.ts}
  touch server/Dockerfile
  touch server/package.json
  echo "Server structure created successfully in 'server/'."
}

# Create server structure
init_server_structure

# Ask for confirmation to proceed with ShadCN initialization
read -p "Do you want to initialize ShadCN for frontend apps? (yes/no): " confirm
if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
  init_shadcn() {
    local app_name=$1
    echo "Initializing ShadCN for $app_name..."
    cd "apps/$app_name"
    pnpm dlx shadcn@latest init -d
    pnpm add -D prettier prettier-plugin-tailwindcss
    echo '{ "plugins": ["prettier-plugin-tailwindcss"] }' > .prettierrc
    echo "ShadCN initialized for $app_name."
    cd ../..
  }

  for app in "${frontend_apps[@]}"; do
    init_shadcn "$app"
  done
else
  echo "ShadCN initialization skipped."
fi

echo "Setup complete!"
