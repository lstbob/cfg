#############################mine
# fzf
eval "$(fzf --bash)"  
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls {}; else cat {}; fi'"

# fzf file and open vim
bind '"\C-f": " \C-e\C-u file=$(fzf --preview '\''bat --color=always {}'\'') && nvim \"$file\" \C-m"'

# vim up and down sugestions
bind '"\C-k": menu-complete'
bind '"\C-j": menu-complete-backward'

#############################mine

