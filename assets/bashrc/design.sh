# -------------------------------------------------------
# Design and Binary Assets Management (for Git projects)
# Written by Nathan Broadbent (www.madebynathan.com)
# -------------------------------------------------------
#
# * The `design` function manages the 'design assets' directories for the current project,
#   including folders such as Backgrounds, Logos, Icons, and Samples. The actual directories are
#   created in $root_design_dir, symlinked into the project, and ignored from source control.
#   This is because we usually don't want to check in large bitmaps or wav files into our code repository,
#   and it also gives us the option to sync $root_design_dir via Dropbox.
#
# Examples:
#
#    $ design link        # Requires SCM Breeze - Links existing design directories into each of your projects
#    $ design init        # Creates default directory structure at $root_design_dir/**/ubuntu_config and symlinks into project.
#                           (Images Backgrounds Logos Icons Mockups Screenshots)
#    $ design init --av   # Creates extra directories for audio/video assets
#                           (Images Backgrounds Logos Icons Mockups Screenshots Animations Videos Flash Music Samples)
#    $ design rm          # Removes any design directories for ubuntu_config
#    $ design trim        # Trims empty design directories for ubuntu_config
#

# Config
# --------------------------
# Directory where design assets are stored
export root_design_dir="$HOME/Dropbox/Design"
# Directory where symlinks are created within each project
export project_design_dir="design_assets"
# Directories for per-project design assets
export design_base_dirs="Images Backgrounds Logos Icons Mockups Screenshots"
export design_av_dirs="Animations Videos Flash Music Samples"
# Directories for global design assets
export design_ext_dirs="Fonts IconSets"


# Add ignore rule to .git/info/exclude if not already present
_design_add_git_exclude(){
  if ! $(touch "$1/.git/info/exclude" && cat "$1/.git/info/exclude" | grep -q "$project_design_dir"); then
    echo "$project_design_dir" >> "$1/.git/info/exclude"
  fi
}

# Manage design directories for project.
design() {
  local project=`basename $(pwd)`
  local all_project_dirs="$design_base_dirs $design_av_dirs"
  # Ensure design dir contains all subdirectories
  unset IFS
  for dir in $design_ext_dirs $design_base_dirs $design_av_dirs; do mkdir -p "$root_design_dir/$dir"; done

  if [ -z "$1" ]; then
    echo "design: Manage design directories for project assets that are external to source control."
    echo
    echo "  Examples:"
    echo
    echo "    $ design init        # Creates default directory structure at $root_design_dir/**/$project and symlinks into project."
    echo "                           ($design_base_dirs)"
    echo "    $ design link        # Links existing design directories into existing repos"
    echo "    $ design init --av   # Adds extra directories for audio/video assets"
    echo "                           ($design_base_dirs $design_av_dirs)"
    echo "    $ design rm          # Removes any design directories for $project"
    echo "    $ design trim        # Trims empty design directories for $project"
    echo
    return 1
  fi

  if [ "$1" = "init" ]; then
    create_dirs="$design_base_dirs"
    if [ "$2" = "--av" ]; then create_dirs+=" $design_av_dirs"; fi
    echo "Creating the following design directories for $project: $create_dirs"
    mkdir -p "$project_design_dir"
    # Create and symlink each directory
    for dir in $create_dirs; do
      mkdir -p "$root_design_dir/$dir/$project"
      if [ ! -e ./$project_design_dir/$dir ]; then ln -sf "$root_design_dir/$dir/$project" $project_design_dir/$dir; fi
    done
    _design_add_git_exclude $PWD

  elif [ "$1" = "link" ]; then
    enable_nullglob
    echo "== Linking existing Design directories into existing repos..."
    for dir in $all_project_dirs; do
      for design_path in $root_design_dir/$dir/*; do
        proj=$(basename $design_path)
        repo_path=$(grep "/$proj$" $GIT_REPO_DIR/.git_index)
        if [ -n "$repo_path" ]; then
          mkdir -p "$repo_path/$project_design_dir"
          if [ -e "$repo_path/$project_design_dir/*" ]; then rm $repo_path/$project_design_dir/*; fi
          _design_add_git_exclude $repo_path
          if ! [ -e "$repo_path/$project_design_dir/$dir" ]; then ln -fs "$design_path" "$repo_path/$project_design_dir/$dir"; fi
          echo "=> $repo_path/$project_design_dir/$dir"
        fi
      done
    done
    disable_nullglob

  elif [ "$1" = "rm" ]; then
    echo "Removing all design directories for $project..."
    for dir in $all_project_dirs; do rm -rf "$root_design_dir/$dir/$project"; done
    rm -rf $project_design_dir

  elif [ "$1" = "trim" ]; then
    echo "Trimming empty design directories for $project..."
    for dir in $(find -L $project_design_dir/ -type d -empty); do
      asset=$(basename $dir)
      rm -rf "$root_design_dir/$asset/$project"
      rm -f $project_design_dir/$asset
    done
    # Remove design dir from project if there's nothing in it.
    if find $project_design_dir -type d -empty | grep -q $project_design_dir; then
      rm -rf $project_design_dir
    fi

  else
    printf "Invalid command.\n\n"
    design
  fi
}

