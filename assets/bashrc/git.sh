#
# Git aliases and functions.
# ----------------------------------------
alias gcl='git clone'
alias gf='git fetch'
alias gpl='git pull'
alias gps='git push'
alias gco='git checkout'
alias grs='git reset'
alias gb='git branch'
alias grb='git rebase'
alias gm='git merge'
alias gcp='git cherry-pick'
# alias ga='git add' - See ga() function.
alias grm='git rm'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit -am'
alias gcm='git commit --amend'
alias gl='git log'
alias gsh='git show'
alias gd='git diff'
alias gdc='git diff --cached'
alias gr='git remote'
# Add all staged changes to latest commit (without changing message)
alias gcmh='git commit --amend -C HEAD'

ours (){ git checkout --ours $1; git add $1; }
theirs (){ git checkout --theirs $1; git add $1; }

# Keyboard bindings
# -----------------------------------------------------------
# Ctrl~>[space] or Ctrl~>x~>[space] gives a git commit prompt,
# where you don't have to worry about escaping anything.
# See here for more info about why this is cool: http://qntm.org/bash#sec1
git_prompt(){ read -e -p "Commit message for '$1': " git_msg; echo $git_msg | $1 -F -; }
case "$TERM" in
xterm*|rxvt*)
    bind "\"\C- \":  \"git_prompt 'git commit -a'\n\""
    bind "\"\C-x \": \"git_prompt 'git commit'\n\""
    ;;
esac

# Attach git tab completion to aliases
complete -o default -o nospace -F _git_pull gpl
complete -o default -o nospace -F _git_push gps
complete -o default -o nospace -F _git_fetch gf
complete -o default -o nospace -F _git_branch gb
complete -o default -o nospace -F _git_rebase grb
complete -o default -o nospace -F _git_merge gm
complete -o default -o nospace -F _git_log gl
complete -o default -o nospace -F _git_checkout gco
complete -o default -o nospace -F _git_remote gr
complete -o default -o nospace -F _git_show gs



# Processes your git status output, exporting bash variables
# for the filepaths of each modified file.
# To ensure colored output, please run: $ git config --global color.status always
# Written by Nathan D. Broadbent (www.madebynathan.com)
# -----------------------------------------------------------
gs() {
  # Set your preferred shortcut letter here
  local pfix="e"
  # Max changes before reverting to standard 'git status' (can be very slow otherwise)
  local max_changes=15
  # ------------------------------------------------
  # Only export variables for less than $max_changes
  local status=`git status --porcelain`
  IFS=$'\n'
  if [ $(echo "$status" | wc -l) -lt $max_changes ]; then
    f=0  # Counter for the number of files
    for line in $status; do
      file=$(echo $line | sed "s/^.. //g")
      let f++
      files[$f]=$file           # Array for formatting the output
      export $pfix$f=$file     # Exporting variable for use.
    done
    full_status=`git status`  # Fetch full status
    # Search and replace each line, showing the exported variable name next to files.
    for line in $full_status; do
      i=1
      while [ $i -le $f ]; do
        search=${files[$i]}
        # Need to strip the color character from the end of the line, otherwise
        # EOL '$' doesn't work. This gave me a headache for long time.
        # The echo ~> regex is very time-consuming, so we perform a simple search first.
        if [[ $line = *$search* ]]; then
          replace="\\\033[2;37m[\\\033[0m\$$pfix$i\\\033[2;37m]\\\033[0m $search"
          line=$(echo $line | sed -r "s:$search(\x1B\[m)?$:$replace:g")
          # Only break the while loop if a replacement was made.
          # This is to support cases like 'Gemfile' and 'Gemfile.lock' both being modified.
          if echo $line | grep -q "\$$pfix$i"; then break; fi
        fi
        let i++
      done
      echo -e $line                        # Print the final transformed line.
    done
  else
    # If there are too many changed files, this 'gs' function will slow down.
    # In this case, fall back to plain 'git status'
    git status
  fi
  # Reset IFS separator to default.
  unset IFS
}

# Can be used in conjunction with the gs() function.
# - Allows you to stage numbered files, ranges of files, or filepaths.
# - Option to detect and use 'git rm' for deleted files.
#   So instead of meaning 'Add file contents to the index',
#   the default meaning of this shortcut is 'stage the change to this file'.
# -------------------------------------------------------------------------------
ga() {
  local pfix="e" # Prefix for environment variable shortcuts
  local auto_remove="yes" # Use 'git rm' for deleted files.
  if [ -z "$1" ]; then
    echo "Usage: ga <file>  => git add <file>"
    echo "       ga 1       => git add \$e1"
    echo "       ga 2..4    => git add \$e2 \$e3 \$e4"
    echo "       ga 2 5..7  => git add \$e2 \$e5 \$e6 \$e7"
    if [[ $auto_remove == "yes" ]]; then
      echo -e "\nNote: Deleted files will also be staged using this shortcut."
      echo "      To turn off this behaviour, change the 'auto_remove' option."
    fi
  else
    # Expand each argument into sets of files.
    for arg in "$@"; do
      # If passed an integer, use the corresponding $e{*} variable
      if [[ "$arg" =~ ^[0-9]+$ ]] ; then
        files=$(eval echo \$$pfix$arg)
      # If passed a range, expand the range for each $e{*} variable
      elif [[ $arg == *..* ]]; then
        files=""
        for i in $(seq $(echo $arg | tr ".." " ")); do
          files="$files $(eval echo \$$pfix$i)"
        done
      # Fall back to treating $arg as a filepath.
      else
        files="$arg"
      fi
      # Process each file
      for file in $files; do
        # If 'auto_remove' is enabled and file doesn't exist,
        # use 'git rm' instead of 'git add'.
        if [[ $auto_remove == "yes" ]] && ! [ -e $file ]; then
          git rm $file
        else
          git add $file
          echo "add '$file'"  # similar output to 'git rm'
        fi
      done
    done
  fi
}


# Permanently remove files/folders from git repository
# -----------------------------------------------------------
# Author: David Underhill
# Script to permanently delete files/folders from your git repository.  To use
# it, cd to your repository's root and then run the script with a list of paths
# you want to delete, e.g., git_remove_history path1 path2
git_remove_history() {
  # Make sure we're at the root of a git repo
  if [ ! -d .git ]; then
      echo "Error: must run this script from the root of a git repository"
      return
  fi
  # Remove all paths passed as arguments from the history of the repo
  files=$@
  git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch $files" HEAD
  # Remove the temporary history git-filter-branch otherwise leaves behind for a long time
  rm -rf .git/refs/original/ && git reflog expire --all &&  git gc --aggressive --prune
}

