<div align="center">
  <h1>❄️ NixOS Personal Configuration</h1>
  <p><i>A declarative, highly modular, and reproducible NixOS environment tailored for development and daily productivity.</i></p>
</div>

---

## 📖 Overview

This configuration is built with a focus on **modular isolation**. Unlike traditional monolithic setups, every major feature (Graphics, Docker, Shell, Cooling, etc.) is contained within its own module. This allows for a system that is both easy to maintain and simple to **tailor** based on your hardware or workflow needs.

**Key Technical Pillars:**
* ⚙️ **Full Modularity:** Every system component is an independent module. If you don't need a feature, you can disable it by simply removing one line.
* 🖥️ **Gnome & Wayland:** Optimized for a smooth and modern graphical experience.
* 🛠️ **Pro Developer Tooling:** Integrated Zsh environment with custom productivity scripts and automated database kits.
* 🌡️ **Integrated Hardware Control:** Custom fan control scripts (NBFC) and system monitoring tools directly tied to Gnome shortcuts.

---

## 🏗️ Modular Architecture

The heart of this setup lies in its modularity. The `configuration.nix` file acts as a central hub that imports specific functionalities from the `./modules/` directory.

**To disable a module:**
If you don't need a specific feature (for example, Docker or the Fan Control system), simply open `configuration.nix` and comment out or remove the corresponding line in the `imports` block:

```nix
  imports = [
    ./hardware-configuration.nix
    ./modules/cooling.nix      # Remove this line to disable fan control entirely
    ./modules/graphics.nix
    # ...
  ];
```

This ensures your system remains lightweight and contains only the tools you actually use.

---

## ⚙️ Installation & Setup

### 1. 📥 Get the Configuration
First, clone your repository into a temporary folder or your home directory:

```bash
git clone https://github.com/Tot0le/NixOS_config.git ~/nixos-config
cd ~/nixos-config
```

### 2. 📂 Backup & Deploy
Before applying the new setup, backup your current configuration and copy the new files to the system directory:

```bash
# Backup existing configuration
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak

# Deploy new configuration
sudo cp -r . /etc/nixos/
cd /etc/nixos/
```

### 3. 👤 User Personalization
Currently, the username `anatole` is hardcoded across several modules (User creation, Docker, Cooling, and Shell). 

> **Note:** A future update will centralize this into a single global variable. For now, to use your own identity, you must manually replace the string `anatole` in the following files:
* `configuration.nix`
* `modules/cooling.nix`
* `modules/docker.nix`
* `modules/shell.nix`

### 4. 🔒 Secrets & Tokens
Sensitive data is isolated in a separate file. Create it from the template:

```bash
cp secrets.nix.template secrets.nix
micro secrets.nix
```
*Note: `secrets.nix` is automatically ignored by Git to prevent data leaks.*

### 5. 🔨 Build the System
Apply the configuration with:

```bash
sudo nixos-rebuild switch
```

---

## 🧰 Development Tools

### 🐘 PostgreSQL Kit (`postgres-kit`)
This configuration includes a template for an isolated PostgreSQL development environment. It allows you to run a local database server within your project folder without affecting the global system.

1. Navigate to your project directory.
2. Run `setup-db`. This copies the template locally and opens it in `nano` for any specific edits.
3. Upon closing the editor, the Nix shell environment launches automatically.
4. Start the server with `pg_ctl start -l logfile`. VSCodium is pre-configured with the "Database Client" extension to connect.
5. Exit the shell with <kbd>Ctrl</kbd> + <kbd>D</kbd>; a `trap` will automatically shut down the database server.

### 🔑 Git Token Manager
A secure script is integrated to quickly copy your GitHub token to the system clipboard:
Run `copyGitToken` in the terminal. The system will prompt for the access code defined in your `secrets.nix`. If successful, the token is copied to the clipboard, and a native notification is sent.

---

## ⌨️ Custom Workflow & Shortcuts

Shortcuts are fully configurable and initialized automatically upon login via `modules/shortcuts.nix`.

| Feature | Keybinding |
| :--- | :--- |
| **Kitty Terminal** | <kbd>Super</kbd> + <kbd>C</kbd> |
| **Firefox Browser** | <kbd>Super</kbd> + <kbd>F</kbd> |
| **Nautilus Explorer** | <kbd>Super</kbd> + <kbd>E</kbd> |
| **Color Picker** | <kbd>Super</kbd> + <kbd>ù</kbd> |

### 📊 Hardware Monitoring
Integrated fan control via <kbd>Super</kbd> + <kbd>F1-F7</kbd> and real-time status updates in the Gnome Top Bar using custom Argos scripts.

---
<p align="center"><i>Built with ❤️ on NixOS</i></p>
