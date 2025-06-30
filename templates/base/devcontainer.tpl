{
  "name": "DevMorph Studio Development Container",
  "dockerComposeFile": [
    "docker-compose.yml"
  ],
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  
  "extensions": [
    "ms-vscode.vscode-json",
    "ms-azuretools.vscode-docker",
    "ms-vscode.vscode-remote-extensionpack",
    "ms-vscode.make",
    "gruntfuggly.todo-tree",
    "oderwat.indent-rainbow",
    "ms-vscode.shellcheck",
    "timonwong.shellscript"
  ],
  
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/git:1": {
      "version": "latest",
      "ppa": true
    }
  },
  
  "remoteUser": "vscode",
  
  "postCreateCommand": "chmod +x ./.devcontainer/post-create.sh && ./.devcontainer/post-create.sh",
  
  "postStartCommand": "chmod +x ./.devcontainer/post-start.sh && ./.devcontainer/post-start.sh"
}