# Define custom environment variables.
# This will overwrite any environment variables defined by `core/environment.zsh`.

# Detect the current OS
# 'darwin' = MacOS
# 'linus'  = linux
export ZSH_HOST_OS=$(uname | awk '{print tolower($0)}')
