# Figure out git remote
remote=$(cat ~/.config/nix-builder-script/config.json | jq .gitRemote -r)
echo "Remote: $remote";
configDir=$(cat ~/.config/nix-builder-script/config.json | jq .configDir -r)
echo "Config dir: $configDir";
outputDir="/etc/nixos";

# Copy over neovim config
cp -r ~/.config/nvim $configDir/src/config/nvim;
tar -czvf ~/.config/nvim.tar.gz ~/.config/nvim; # Backup the neovim config

# Make a unified commit message for the configuration
git -C $configDir pull;
version=$(git -C $configDir log --oneline | wc -l);
commitMsg="V$version - $(date -u +"%Y-%m-%dT%H:%M:%SZ")";
echo "Commit message: $commitMsg";

# Add all files in the config directory
git -C $configDir add --a;
echo "Added all files in the nix config dir";
commitResult=$(git -C $configDir commit -m "$commitMsg");
if [[ $commitResult == *"nothing to commit"* ]]; then
    echo "No changes to commit";
    exit 0;
fi
echo "Commited all changes in the nix config dir";
git -C $configDir push;
echo "Commited and pushed all changes to nix config dir";

# Pull the latest changes from the nix config dir
sudo git -C $outputDir pull;
echo "Pulled latest changes from the nix config dir";

# Figure out if the user command is 'nix' or 'home'
COMMAND=$1;

# If the command is 'nix', then rebuild the system
case $COMMAND in
    "nix")
        sudo nixos-rebuild --flake $outputDir switch;
        exit 0;
        ;;
    "home")
        sudo home-manager --flake $outputDir#wolf switch;
        exit 0;
        ;;
    *)
        echo "Invalid command: $COMMAND";
        exit 1;
        ;;
esac
