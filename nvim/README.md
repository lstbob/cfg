# Neovim configuration
## Summary
Neovim configuration for C# and dotnet development with minimal setup and only a couple of must-have
plug-ins. Setup is meant to be done on Debian 12 (Bookworm) with the latest Neovim version (at the
time of posting 0.11.3)
### Installation
1. Neovim app image is needed since installation through apt on bookworm will default to a version 0.7* which does not support some lua script features. Find the latest stable release
2. After download give the nvim.appimage file executable permissions with:
<code>chmod u+x nvim.appimage </code> 
3. Move the nvim.appimage file to PATH :
<code>mv nvim.appimage /usr/local/bin/nvim</code>
4. Install the .NET sdk and runtime (for Debian 12 must be .9 or above). Follow instructions 
from the Debian [installation page](https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian?tabs=dotnet9)
or run the following commands:

    download the deb package and depackage it
    <code>curl https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    </code>

    install the sdk
    <code>sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-9.0
    </code>

    install the runtime
    <code>sudo apt-get install -y dotnet-runtime-9.0
    </code>

5. Install ripgrep to be able to use telescope's fuzzy finder.
    <code>
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
    $ sudo dpkg -i ripgrep_14.1.1-1_amd64.deb
    </code>
6. Clone the repo into your <code>.config</code> folder so that it is in the follwoing path:
    <code>~/.config/nvim</code>
7. Open up nvim and run :PackerSync to install all plug-ins.
8. Check to see if you have roslyn installed. If not you should install it manually with
    <code>:MasonInstall roslyn</code>. The additonal registries are already added to the mason config
    so it should work out of the box.
9. Install clipboard tool for multipe register copy/paste support.
   <code>sudo apt install xsel</code> 

10. Install formatters for different languages so that conform.nvim plugin can autoformat
C#	CSharpier	dotnet tool install -g csharpier	Autoformats C# according to Roslyn rules. Add to PATH: export PATH="$PATH:$HOME/.dotnet/tools"
JavaScript / TypeScript / YAML / JSON	Prettierd (recommended)	npm i -g @fsouza/prettierd	Super-fast daemonized prettier.
Fallback if needed: npm i -g prettier
Rust	rustfmt	rustup component add rustfmt	Usually included with Rust.
Go	gofmt	already comes with Go	Nothing extra needed.
Python	black	pip install black	Strict PEP8 formatting.
SQL	sqlfluff	pip install sqlfluff	Optional dialect flag later.
C	clang-format	sudo apt install clang-format (Linux)
or brew install clang-format (macOS)	Works for both C/C++ files.
