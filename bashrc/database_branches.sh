DATABASE_BRANCHES_FILE=".database_branches~"
DATABASE_USER="root"

add_branched_db() {
  database=$(rails_database development database)
  branch=$(parse_git_branch)
  branched_db="${database}_${branch}"

  # Copy original database to new database
  if [ $(rails_database development adapter) = 'mysql2' ]; then
    mysql -u $DATABASE_USER -e "CREATE DATABASE IF NOT EXISTS $branched_db;"
    mysqldump -u $DATABASE_USER "$database" | mysql -u $DATABASE_USER "$branched_db"
    echo "Copied '$database' to '$branched_db'."
  fi

  # Add entry to branch index, so that DB_SUFFIX is exported when switching branches
  echo "$branch" >> $DATABASE_BRANCHES_FILE
  echo "Added database branches entry for '$branch' branch."
}

rm_branched_db() {
  database=$(rails_database development database)
  branch=$(parse_git_branch)
  branched_db="${database}_${branch}"

  # Drop branched database
  if [ $(rails_database development adapter) = 'mysql2' ]; then
    mysql -u $DATABASE_USER -e "DROP DATABASE IF EXISTS $branched_db;"
    echo "Dropped '$branched_db' database."
  fi

  # Remove entry from branch index
  if [ -e $DATABASE_BRANCHES_FILE ]; then
    sed "/^$branch/d" -i $DATABASE_BRANCHES_FILE
    echo "Deleted database branches entry for '$branch' branch."
  fi
}

# Checks branch, and exports DB_SUFFIX if there's a corresponding entry in DATABASE_BRANCHES_FILE
set_db_name_for_branch() {
  if [ -e $DATABASE_BRANCHES_FILE ]; then
    branch=$(parse_git_branch)
    if grep -q "^$branch" $DATABASE_BRANCHES_FILE; then
      export DB_SUFFIX="_$branch"
    else
      unset DB_SUFFIX
    fi
  fi
}

# Add branch check to prompt command
autoreload_prompt_command+="set_db_name_for_branch;"