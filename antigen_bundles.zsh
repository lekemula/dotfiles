# Additional oh-my-zsh plugins to include
# Default bundles included can be seen in core/default_bundles.zsh
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins for available oh-my-zsh plugins.
# See https://github.com/zsh-users/antigen/wiki/Commands#antigen-bundle for instructions on including custom plugins.
#
# Include a plugin with `antigen bundle <plugin-name>`.

# Do not wrap `antigen theme` or `antigen bundle` in conditions. Antigen has cache invalidation issues.
# If you want to conditionally load bundles, uncomment the following line:
# ANTIGEN_CACHE=false
# You can read more in https://github.com/zsh-users/antigen/wiki/Commands#antigen-theme for info on how to define
# custom caching keys for different environments, if you desire that. The cache speeds up your terminal startup, so
# try to avoid disabling the cache unless you have no other choice.

# Check loaded plugins:
# antigen list
#
# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Staples theme: https://github.com/romkatv/powerlevel10k
antigen theme romkatv/powerlevel10k

# https://github.com/zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-autosuggestions
# https://github.com/zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-syntax-highlighting
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases
antigen bundle aliases
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
antigen bundle git
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/bundler
antigen bundle bundler
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
antigen bundle dotenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
antigen bundle macos
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rake
antigen bundle rake
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rbenv
antigen bundle rbenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ruby
antigen bundle ruby
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rails
antigen bundle rails
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
antigen bundle docker
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose
antigen bundle docker-compose
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl
antigen bundle kubectl
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/helm
antigen bundle helm
# https://github.com/jeffreytse/zsh-vi-mode
antigen bundle jeffreytse/zsh-vi-mode
