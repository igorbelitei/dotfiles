# -------------------------------------------------------
# Prompt / Xterm
# -------------------------------------------------------

# Prompt colors
_txt_col="\033[00m"     # Std text (white)
_bld_col="\033[01;37m"  # Bold text (white)
_wrn_col="\033[01;31m"  # Warning
_sep_col=$_txt_col      # Separators
_usr_col="\033[01;32m"  # Username
_cwd_col=$_txt_col      # Current directory
_hst_col="\033[0;32m"   # Host
_env_col="\033[0;36m"   # Prompt environment
_git_col="\033[01;36m"  # Git branch

# Returns the current git branch (returns nothing if not a git repository)
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Returns the current ruby version.
parse_ruby_version() {
  if (which ruby | grep -q ruby); then
    ruby -v | cut -d ' ' -f2
  fi
}

# Set the prompt string (PS1)
set_ps1() {
  user_str="\[$_usr_col\]\u\[$_hst_col\]@\h\[$_txt_col\]"
  dir_str="\[$_cwd_col\]\w"
  git_branch=`parse_git_branch`
  ruby=`parse_ruby_version`
  if [ -n "$git_branch" ]; then git_branch="\[$_git_col\]$git_branch\[$_env_col\]"; fi   # -- colorize
  if [ -n "$git_branch" ] && [ -n "$ruby" ]; then git_branch="$git_branch|"; fi  # -- separator
  if [ -n "$git_branch" ] || [ -n "$ruby" ]; then
    env_str="\[$_env_col\][$git_branch$ruby\[$_env_col\]]"
  else
    unset env_str
  fi
  PS1="${debian_chroot:+($debian_chroot)}$user_str $dir_str $env_str\[$_sep_col\]$ \[$_txt_col\]"
}

# Set custom prompt
PROMPT_COMMAND='set_ps1;'

# Custom Xterm/RXVT Title
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND+='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007";'
    ;;
*)
    ;;
esac

# Correct spelling errors for 'cd' command, and auto cd to directory
# Only run this for debian systems (AWS doesn't have 'shopt')
if [ -f /etc/debian_version ]; then
  shopt -s cdspell
  shopt -s autocd
fi
