# DevMorph AI Studio - Workspace Manager Examples and Tutorials

## Quick Start Guide

### Installation and Setup

```bash
# Clone the repository
git clone https://github.com/devmorph/workspace-manager.git
cd workspace-manager

# Make scripts executable
chmod +x *.sh */*.sh */*/*.sh

# Verify Docker installation
docker --version
docker-compose --version

# Check if Docker daemon is running
docker info
```

### Creating Your First Workspace

```bash
# Create a basic development workspace
devmorph workspace create --name my-first-project --template default --mode dev

# Start the workspace
devmorph workspace start my-first-project

# Check workspace status
devmorph workspace list

# Access your workspace at http://localhost:3000

# Stop the workspace when done
devmorph workspace stop my-first-project
```

## Common Workflows

### Feature Development

```bash
# Create feature workspace
devmorph workspace create --name feature-user-auth --template default --mode dev

# Start development
devmorph workspace start feature-user-auth
cd feature-user-auth

# Make code changes
echo '
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "Hello World" });
});

app.listen(3000, () => console.log("Server started"));
' > src/index.js

# Test changes at http://localhost:3000

# Commit changes
git init
git add .
git commit -m "Add basic endpoint"

# Clean up
cd ..
devmorph workspace stop feature-user-auth
devmorph workspace destroy feature-user-auth --force
```

### Testing Workflow

```bash
# Create test workspace
devmorph workspace create --name automated-tests --template default --mode test

# Start in test mode
devmorph workspace start automated-tests
cd automated-tests

# Run tests
echo '
#!/usr/bin/env node
const assert = require("assert");
const http = require("http");

async function runTests() {
  console.log("Running tests...");
  
  // Test server responds
  await new Promise((resolve, reject) => {
    http.get("http://localhost:3000", (res) => {
      assert.strictEqual(res.statusCode, 200);
      console.log("✓ Server responds with 200 OK");
      resolve();
    }).on("error", reject);
  });
  
  console.log("All tests passed!");
}

runTests().catch(err => {
  console.error("Test failed:", err);
  process.exit(1);
});
' > test.js

node test.js

# Clean up
cd ..
devmorph workspace stop automated-tests
devmorph workspace destroy automated-tests --force
```

## Advanced Features

### Multi-Service Architecture

```bash
# Create complex workspace
devmorph workspace create --name microservices-arch --template default --mode dev

cd microservices-arch

# Update docker-compose.yml for microservices
echo '
version: "3.8"
services:
  gateway:
    build: ./gateway
    ports:
      - "3000:3000"
    depends_on:
      - user-service
    environment:
      - USER_SERVICE_URL=http://user-service:3001

  user-service:
    build: ./services/user
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=postgresql://user:password@user-db:5432/users
    depends_on:
      - user-db

  user-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
' > docker-compose.yml

# Create service directories
mkdir -p {gateway,services/user}

# Create simple implementations
echo '
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ service: "API Gateway" });
});

app.listen(3000, () => console.log("Gateway listening"));
' > gateway/index.js

echo '
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ service: "User Service" });
});

app.listen(3001, () => console.log("User service listening"));
' > services/user/index.js

# Update package.json files
echo '{"dependencies":{"express":"^4.18.0"}}' > gateway/package.json
echo '{"dependencies":{"express":"^4.18.0"}}' > services/user/package.json

# Start the workspace
cd ..
devmorph workspace start microservices-arch

# Test services
curl -s http://localhost:3000/ | jq
curl -s http://localhost:3001/ | jq

# Clean up
devmorph workspace stop microservices-arch
devmorph workspace destroy microservices-arch --force
```

## Real-world Examples

### Web Application Development

```bash
# Create web application workspace
devmorph workspace create --name web-app --template default --mode dev

cd web-app

# Create realistic project structure
mkdir -p {src/{controllers,models,routes},public/{css,js,images},views,tests}

# Create package.json
echo '{
  "name": "web-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "mongoose": "^6.0.0"
  }
}' > package.json

# Create basic application
echo '
const express = require("express");
const app = express();

app.use(express.static("public"));

app.get("/", (req, res) => {
  res.send("<h1>Welcome to Web App</h1>");
});

app.listen(3000, () => console.log("Web app started"));
' > src/app.js

# Start workspace
cd ..
devmorph workspace start web-app

# Access at http://localhost:3000

# Clean up
devmorph workspace stop web-app
devmorph workspace destroy web-app --force
```

## Custom Templates

### Creating a React Template

```bash
# Create templates directory if it doesn't exist
mkdir -p templates/react-basic

cd templates/react-basic

# Create package.json
echo '{
  "name": "react-basic-template",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-scripts": "5.0.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  }
}' > package.json

# Create basic React app structure
mkdir -p src public

echo '<!DOCTYPE html>
<html>
<head>
  <title>React App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>' > public/index.html

echo 'import React from "react";
import ReactDOM from "react-dom/client";

function App() {
  return <h1>Hello, React!</h1>;
}

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);' > src/index.js

# Create Docker Compose file
echo 'version: "3.8"
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src
    environment:
      - CHOKIDAR_USEPOLLING=true' > docker-compose.yml

# Create Dockerfile
echo 'FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]' > Dockerfile

# Use the new template
cd ../../../
devmorph workspace create --name my-react-app --template react-basic --mode dev
devmorph workspace start my-react-app

# Access at http://localhost:3000

# Clean up
devmorph workspace stop my-react-app
devmorph workspace destroy my-react-app --force
```

## Integration Examples

### CI/CD Pipeline Integration

```yaml
# .github/workflows/test.yml
name: Test Workspace

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker
      uses: docker/setup-buildx-action@v2
    
    - name: Create test workspace
      run: |
        chmod +x ./devmorph
        ./devmorph workspace create --name ci-test --template default --mode test
    
    - name: Run tests
      run: |
        ./devmorph workspace start ci-test
        sleep 10
        # Run test suite
        docker-compose exec -T app npm test
    
    - name: Clean up
      if: always()
      run: |
        ./devmorph workspace destroy ci-test --force
```

## Best Practices Demonstrations

### Environment-Specific Configurations

```bash
# Create workspace with environment configs
devmorph workspace create --name env-config-demo --template default --mode dev

cd env-config-demo

# Create environment files
echo 'NODE_ENV=development
API_URL=http://localhost:3000
DEBUG=true' > .env.development

echo 'NODE_ENV=staging
API_URL=https://staging.api.example.com
DEBUG=false' > .env.staging

echo 'NODE_ENV=production
API_URL=https://api.example.com
DEBUG=false' > .env.production

# Use environment in application
echo '
const express = require("express");
const app = express();

// Load environment variables
require("dotenv").config();

app.get("/config", (req, res) => {
  res.json({
    environment: process.env.NODE_ENV,
    apiUrl: process.env.API_URL,
    debug: process.env.DEBUG
  });
});

app.listen(3000, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode`);
});
' > src/index.js

# Update package.json to include dotenv
echo '{
  "dependencies": {
    "express": "^4.18.0",
    "dotenv": "^16.0.0"
  }
}' > package.json

# Test different environments
# Development mode
cd ..
devmorph workspace start env-config-demo

curl http://localhost:3000/config

# Switch to staging
devmorph workspace stop env-config-demo
devmorph workspace mode set env-config-demo --mode staging
cp .env.staging env-config-demo/.env
devmorph workspace start env-config-demo

curl http://localhost:3000/config

# Clean up
devmorph workspace stop env-config-demo
devmorph workspace destroy env-config-demo --force
```

---

*Last updated: July 03, 2025*