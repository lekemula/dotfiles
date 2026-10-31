# Lean prompt for Rex, layered over ~/.p10k.zsh by custom.zsh when $TERM_PROGRAM is
# rex. Rex's UI is flat, so instead of powerline blocks this drops every segment
# background and separator and colours text with Rex's merino-dark palette (GitHub
# Dark Default).

# No blocks: clear every segment background ~/.p10k.zsh set, and the arrows.
typeset -g POWERLEVEL9K_BACKGROUND=
for _p10k_rex_bg in ${(M)${(k)parameters}:#POWERLEVEL9K_*_BACKGROUND}; do
  typeset -g $_p10k_rex_bg=
done
unset _p10k_rex_bg
# Single spaces between segments, none at the edges (p10k's lean style).
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs prompt_char)
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#3fb950'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#ff7b72'
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=

typeset -g POWERLEVEL9K_DIR_FOREGROUND='#58a6ff'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#388bfd'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#79c0ff'
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=

typeset -g P10K_GIT_META='%F{#8b949e}'
typeset -g P10K_GIT_CLEAN='%F{#3fb950}'
typeset -g P10K_GIT_MODIFIED='%F{#d29922}'
typeset -g P10K_GIT_UNTRACKED='%F{#58a6ff}'
typeset -g P10K_GIT_CONFLICTED='%F{#ff7b72}'

typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#3fb950'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#ff7b72'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#d29922'
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#8b949e'
