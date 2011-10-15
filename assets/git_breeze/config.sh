#
# Git File Shortcuts Config
# ------------------------------------------------------------------------------
# - Set your preferred prefix for env variable file shortcuts.
#   (I chose 'e' because it is the easiest key to press after '$'.)
git_env_char="e"
# - Max changes before reverting to 'git status'. git_status_shortcuts() may slow down for lots of changes.
gs_max_changes="99"
# - Automatically use 'git rm' to remove deleted files when using the git_add_with_shortcuts() command?
ga_auto_remove="yes"


# Git Repo Management Config
# --------------------------
# Repos will be automatically added from this directory.
GIT_REPO_DIR="$HOME/src"
# Add the full paths of any extra repos to GIT_REPOS, separated with ':'
# e.g. "/opt/rails/project:/opt/rails/another project:$HOME/other/repo"
GIT_REPOS=""
git_status_command="git_status_shortcuts"



# Alias configuration
# (1. and 2. are important to define, but feel free to skip 3. if you don't need them)
# ------------------------------------------------------------------------------------

git_alias="g"

# 1. 'Git Breeze' functions
git_status_shortcuts_alias="gs"
git_add_shortcuts_alias="ga"
git_show_files_alias="gsf"
exec_git_expand_args_alias="ge"
# 2. Commands that handle paths (with shortcut args expanded)
git_checkout_alias="gco"
git_commit_alias="gc"
git_reset_alias="grs"
git_rm_alias="grm"
git_blame_alias="gbl"
git_diff_alias="gd"
git_diff_cached_alias="gdc"
# 3. Standard commands
git_clone_alias="gcl"
git_fetch_alias="gf"
git_fetch_and_rebase_alias="gfr"
git_pull_alias="gpl"
git_push_alias="gps"
git_status_original_alias="gst"
git_status_short_alias="gss"
git_add_all_alias="gaa"
git_commit_all_alias="gca"
git_commit_amend_alias="gcm"
git_commit_amend_no_msg_alias="gcmh"
git_remote_alias="gr"
git_branch_alias="gb"
git_branch_all_alias="gba"
git_rebase_alias="grb"
git_merge_alias="gm"
git_cherry_pick_alias="gcp"
git_log_alias="gl"
git_log_stat_alias="gls"
git_log_graph_alias="glg"
git_show_alias="gsh"

# Git repo management
git_repo_alias="s"


# Keyboard shortcuts configuration
# ---------------------------------------------
git_status_shortcuts_keys="\C- "   # CTRL+SPACE
git_commit_all_keys="\C-x "        # CTRL+x SPACE
git_add_and_commit_keys="\C-xc"    # CTRL+x c

