# Figure out git remote
remote=$(cat ~/.config/nix-builder-script/config.json | jq .gitRemote -r)
echo "Remote: $remote";
configDir=$(cat ~/.config/nix-builder-script/config.json | jq .configDir -r)
echo "Config dir: $configDir";
outputDir="/etc/nixos";

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

sleep(1);

# Pull the latest changes from the nix config dir
sudo git -C $outputDir pull;
echo "Pulled latest changes from the nix config dir";

# Rebuild the system
sudo nixos-rebuild --flake /etc/nixos switch;
