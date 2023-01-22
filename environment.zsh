# Define custom environment variables.
# This will overwrite any environment variables defined by `core/environment.zsh`.

# Detect the current OS
# 'darwin' = MacOS
# 'linus'  = linux
export ZSH_HOST_OS=$(uname | awk '{print tolower($0)}')
export PERSONAL_DOTFILES_DIRECTORY_NAME=$([ $SHOPIFY ] && echo "$DOTFILES_DIRECTORY_NAME/personal" || echo $DOTFILES_DIRECTORY_NAME)
echo "Personal dir: $PERSONAL_DOTFILES_DIRECTORY_NAME"
