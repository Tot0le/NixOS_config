<div align="center">
  <img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nixos.svg" alt="NixOS Logo" width="250"/>
  <br/><br/>
  <h1>NixOS Personal Configuration</h1>
  <p><i>A declarative, highly modular, and reproducible NixOS environment tailored for development and daily productivity.</i></p>

  <p>
    <img src="https://img.shields.io/badge/NixOS-25.11-5277C3.svg?style=for-the-badge&logo=NixOS&logoColor=white" alt="NixOS Version" />
    <img src="https://img.shields.io/badge/Home_Manager-Enabled-FF7A00.svg?style=for-the-badge&logo=NixOS&logoColor=white" alt="Home Manager" />
    <img src="https://img.shields.io/badge/Shell-Zsh-181717.svg?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zsh" />
    <img src="https://img.shields.io/badge/Containers-Docker-2496ED.svg?style=for-the-badge&logo=Docker&logoColor=white" alt="Docker" />
  </p>
</div>

---

## 📑 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Installation & Setup](#installation)
- [Development Tools](#tools)
- [Custom Workflow & Shortcuts](#shortcuts)

---

## <a id="overview"></a>📖 Overview

This configuration is built with a dual focus on **modular isolation** and **Standalone Workspace Architecture**. While core system features (Hardware, Docker, Cooling) are contained within independent NixOS modules, user environments (dotfiles, terminal, tools) are fully isolated and provisioned automatically using **Home Manager**.

**Key Technical Pillars:**
* ⚙️ **System Modularity:** Every system component is an independent module. If you don't need a feature, you can disable it by simply removing one line. This ensures your system remains lightweight and contains only the tools you actually use.
* 📦 **Zero-Touch Provisioning:** When a new user opens their terminal for the first time, their personal `home.nix` workspace is automatically compiled and activated.
* 🛠️ **Pro Developer Tooling:** Isolated Zsh environments, Kitty terminal, automated PostgreSQL database kits, and safe custom shortcut bindings.
* 🌡️ **Integrated Hardware Control:** Custom fan control scripts (NBFC) tied to GNOME shortcuts and top-bar monitoring.

---

## <a id="architecture"></a>🏗️ Architecture

The `configuration.nix` acts as the central hub. It defines system-level imports and declares the user profiles.

* **`/modules/`**: System-wide capabilities (Docker, VirtualBox, Cooling, Monitoring).
* **`/templates/`**: Project-specific `nix-shell` environments (Java, Minecraft, PostgreSQL).
* **`/users/layouts/`**: Base profile definitions (e.g., `all-Feature` or `simple`).
* **`/users/features/`**: Granular, plug-and-play user app modules (e.g., `kathara.nix`).

When a user is created, an **Activation Script** assigns them a layout (e.g., `all-Feature` or `simple`) and generates a standalone `home-manager` template in their personal directory, which they can then edit freely.

---

## <a id="installation"></a>⚙️ Installation & Setup

### 1. 📥 Get the Configuration

1. **Enter a temporary shell with Git** (required if Git is not yet installed on your system):
   ```bash
   nix-shell -p git
   ```
   
2. **Backup your hardware profile** (vital for your specific machine):
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix /tmp/
   ```
3. **Clone the repository** (this will empty the directory first):
   ```bash
   sudo rm -rf /etc/nixos/*
   sudo git clone https://github.com/Tot0le/NixOS_config.git /etc/nixos
   ```
4. **Restore your hardware profile**:
   ```bash
   sudo cp /tmp/hardware-configuration.nix /etc/nixos/
   ```

### 2. 👤 Provisioning Users
To add or modify users, update the `usersConfigs` attribute set at the top of `configuration.nix`:

```nix
  usersConfigs = {
    yourname = { fullName = "Your Name"; isAdmin = true; layout = "all-Feature"; };
  };
```

### 3. 🔨 Build the System
Apply the global configuration:

```bash
sudo nixos-rebuild switch
```

### 4. 🚀 Auto-Initialization & Permissions
1. **Fix Git Permissions**: Because the repo was cloned using sudo, you must claim ownership of the configuration folder so your local Zsh/Git prompts can read it properly:

```bash
sudo chown -R $USER:users /etc/nixos
```

2. **Initialize Workspace**: Open your terminal. The system will detect your uninitialized workspace, automatically install Home Manager, apply your layout, and prompt you to restart your shell to enjoy Zsh.

---

## <a id="tools"></a>🧰 Development Tools

### 🌐 Network Emulation (kathará)
A fully configured network emulation environment utilizing Docker. It is modularized within features/kathara.nix and natively defaults to xterm to ensure robust rendering of virtual device consoles without Wayland/OpenGL conflicts.

### 🐘 PostgreSQL Kit (`postgres-kit`)
This configuration includes a template for an isolated PostgreSQL development environment. It allows you to run a local database server within your project folder without affecting the global system.

1. Navigate to your project directory.
2. Run `setup-db`. This copies the template locally and opens it in `nano` for any specific edits.
3. Upon closing the editor, the Nix shell environment launches automatically.
4. Start the server with `pg_ctl start -l logfile`. VSCodium is pre-configured with the "Database Client" extension to connect.
5. Exit the shell with <kbd>Ctrl</kbd> + <kbd>D</kbd>; a `trap` will automatically shut down the database server.

### ☕ Java & Minecraft Kits
Use `setup-java` (JDK 21, JavaFX, Maven) or `setup-minecraft` (JDK 25, Playit.gg) to instantly deploy isolated project environments with proper library pathing for graphical interfaces.

### 🔑 Local Git Token Manager
A secure, per-user script to copy your GitHub token to the Wayland clipboard:
1. Run `copyGitToken`. On the first run, it will interactively prompt you to store your token and create a local access PIN.
2. Credentials are automatically locked down (`chmod 600`) in `~/.config/`.
3. Subsequent runs will only require your PIN to copy the token and trigger a GNOME notification.

---

## <a id="shortcuts"></a>⌨️ Custom Workflow & Shortcuts

Shortcuts are fully configurable and initialized automatically upon login via `modules/shortcuts.nix`.

| Feature | Keybinding |
| :--- | :--- |
| **Kitty Terminal** | <kbd>Super</kbd> + <kbd>C</kbd> |
| **Firefox Browser** | <kbd>Super</kbd> + <kbd>F</kbd> |
| **Nautilus Explorer** | <kbd>Super</kbd> + <kbd>E</kbd> |
| **Color Picker** | <kbd>Super</kbd> + <kbd>ù</kbd> |
| **Fan Control** | <kbd>Super</kbd> + <kbd>F1-F7</kbd> |

### 📊 Hardware Monitoring
Integrated fan control via <kbd>Super</kbd> + <kbd>F1-F7</kbd> and real-time status updates in the Gnome Top Bar using custom Argos scripts.

---
<p align="center"><i>Built with ❤️ on NixOS</i></p>
