# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# ne rien faire en mode non interactif
[ -z "$PS1" ] && return

# ne pas mettre en double dans l'historique les commandes tapées 2x
export HISTCONTROL=ignoredups
# lignes de l'historique par session bash
export HISTSIZE=5000
# lignes de l'historique conservées
export HISTFILESIZE=20000
# supporte des terminaux redimensionnables (xterm et screen -r)
shopt -s checkwinsize

# une commande fréquemment utilisée
alias ll='ls -l'
# utilisation des couleurs pour certaines commandes
eval "`dircolors -b`"
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Interdire l'écrasement de fichier avec >
set -C

# affichage sympathique de la ligne de commande
BLACK=`tput setf 0`
BLUE=`tput setf 1`
GREEN=`tput setf 2`
CYAN=`tput setf 3`
RED=`tput setf 4`
MAGENTA=`tput setf 5`
YELLOW=`tput setf 6`
WHITE=`tput setf 7`

if [ "$LOGNAME" = "root" ]
then
	PS1="\[$RED\]\t \u@\H:\[$CYAN\]\w \[$MAGENTA\][\!]\$ \[$BLACK\] \n"
else
	PS1="\[$GREEN\]\t \u@\H:\[$CYAN\]\w \[$MAGENTA\][\!]\$ \[$BLACK\] \n" 
fi


# permettre une complétion plus "intelligente" des commandes (question de goût)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# lecture colorée de logs
logview()
{
    ccze -A < $1 | less -R
}

# lecture colorée de logs en directfunction logview()
logtail()
{
    tail -f $1 | ccze
}



# Pour afficher user@host dans le titre de la fenêtre de terminal :
#PROMPT_COMMAND='echo -ne "33]0;$(id -un)@$(hostname -s)07"'

# Pour définir l'éditeur par défaut utilisé par de nombreuses commandes (vipw, visudo, less, cvs, svn...) :
export EDITOR=vim

# Pour ceux qui sont frileux (demande confirmation de chaque suppression ou écrasement) :
alias cp='cp -ip' # -p : conserve les dates, droits lors de la copie
alias mv='mv -i'
alias rm='rm -i'

# Quelques paramètres pratiques :
alias ls='ls -AhF'
# -A : affiche aussi les fichiers commençant par un point
# -h : affiche la taille avec B/K/M/G;
# -F : affiche un caractère à la fin du nom indiquant le type de fichier
alias ll='ls -lo'
# -o : affiche les flags, pratique pour détecter les uchg (cf chflags(1))
alias chown='chown -h'
# -h : pour un lien, change le propriétaire/groupe du lien lui même

# Pour permettre de taper des caractères accentués dans le shell :
bind 'set convert-meta off'

###################################################################
# by Ebzao
##########

# utilisation de most (avec les couleurs) si disponible
export PAGER=`which most`
export PAGER=${PAGER:-less}

# Pour les gros doigts
alias cd..='cd ..'
alias grpe='grep'
alias mroe='more'
alias iv='vi'
alias tial='tail'
alias xs='cd'
alias vf='cd'
alias ..=' cd ..'

# Ne pas garder les trucs inutiles dans les logs (attention peut casser certaines habitudes)
export HISTIGNORE="cd:ls:[bf]g:clear"

# Correction automatique des petites typos
shopt -s cdspell
alias du='du -h --max-depth=1'
alias dusort='du -x --block-size=1048576 | sort -nr'
alias df='df -h'
alias ap="sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude full-upgrade && sudo aptitude autoclean"
