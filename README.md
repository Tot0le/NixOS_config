<div align="center">
  <h1>❄️ NixOS Personal Configuration</h1>
  <p><i>A declarative, highly modular, and reproducible NixOS environment tailored for development and daily productivity.</i></p>
</div>

---

## 📖 Overview

This configuration is built with a dual focus on **modular isolation** and **Standalone Workspace Architecture**. While core system features (Hardware, Docker, Cooling) are contained within independent NixOS modules, user environments (dotfiles, terminal, tools) are fully isolated and provisioned automatically using **Home Manager**.

**Key Technical Pillars:**
* ⚙️ **System Modularity:** Every system component is an independent module. If you don't need a feature, you can disable it by simply removing one line. This ensures your system remains lightweight and contains only the tools you actually use.
* 📦 **Zero-Touch Provisioning:** When a new user opens their terminal for the first time, their personal `home.nix` workspace is automatically compiled and activated.
* 🛠️ **Pro Developer Tooling:** Isolated Zsh environments, Kitty terminal, automated PostgreSQL database kits, and safe custom shortcut bindings.
* 🌡️ **Integrated Hardware Control:** Custom fan control scripts (NBFC) tied to GNOME shortcuts and top-bar monitoring.

---

## 🏗️ Architecture

The `configuration.nix` acts as the central hub. It defines system-level imports and declares the user profiles.

When a user is created, an **Activation Script** assigns them a layout (e.g., `all-Feature` or `simple`) and generates a standalone `home-manager` template in their personal directory, which they can then edit freely.

---

## ⚙️ Installation & Setup

### 1. 📥 Get the Configuration

1. **Backup your hardware profile** (vital for your specific machine):
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix /tmp/
   ```
2. **Clone the repository** (this will empty the directory first):
   ```bash
   sudo rm -rf /etc/nixos/*
   sudo git clone https://github.com/Tot0le/NixOS_config.git /etc/nixos
   ```
3. **Restore your hardware profile**:
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

### 4. 🚀 Auto-Initialization
Log in to your new user account and open the terminal. The system will detect your uninitialized workspace, automatically install Home Manager, apply your specific layout, and prompt you to restart your shell to enjoy Zsh.

---

## 🧰 Development Tools

### 🐘 PostgreSQL Kit (`postgres-kit`)
This configuration includes a template for an isolated PostgreSQL development environment. It allows you to run a local database server within your project folder without affecting the global system.

1. Navigate to your project directory.
2. Run `setup-db`. This copies the template locally and opens it in `nano` for any specific edits.
3. Upon closing the editor, the Nix shell environment launches automatically.
4. Start the server with `pg_ctl start -l logfile`. VSCodium is pre-configured with the "Database Client" extension to connect.
5. Exit the shell with <kbd>Ctrl</kbd> + <kbd>D</kbd>; a `trap` will automatically shut down the database server.

### 🔑 Local Git Token Manager
A secure, per-user script to copy your GitHub token to the Wayland clipboard:
1. Run `copyGitToken`. On the first run, it will interactively prompt you to store your token and create a local access PIN.
2. Credentials are automatically locked down (`chmod 600`) in `~/.config/`.
3. Subsequent runs will only require your PIN to copy the token and trigger a GNOME notification.

---

## ⌨️ Custom Workflow & Shortcuts

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
