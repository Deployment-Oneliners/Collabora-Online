#!/bin/bash

call_ssl4tor() {
  local external_nextcloud_port="$1"
  local local_nextcloud_port="$2"
  local ssl_password="$3"

  local github_username="hiveminds"
  local repo_name="ssl4tor"
  # Clone the repository if it does not exist.
  ensure_https_github_repo_is_cloned "$github_username" "$repo_name" "$SSL4TOR_DIR"

  # Go into GitHub repo.
  local current_path="$PWD"

  # Run command.
  cd "$SSL4TOR_DIR" && ./src/main.sh \
    --delete-onion-domain \
    --delete-projects-ssl-certs \
    --delete-root-ca-certs \
    --firefox-to-apt \
    --services "$local_nextcloud_port:nextcloud:$external_nextcloud_port" \
    --ssl-password "$ssl_password" \
    --get-onion-domain

  # Return to current path.
  cd "$current_path" || exit 5

}

# Structure:github_modify
ensure_https_github_repo_is_cloned() {
  if [[ "$1" != "" ]] && [[ "$2" != "" ]] && [[ "$3" != "" ]]; then
    local github_username="$1"
    local github_repository="$2"
    local target_directory="$3"
  else
    echo "ERROR, incoming args not None."
    exit 14
  fi

  # Remove target directory if it already exists.
  if [[ ! -d "$target_directory" ]]; then
    git clone --quiet https://github.com/"$github_username"/"$github_repository".git "$target_directory"
  else
    local current_path="$PWD"

    cd "$target_directory" && git pull

    cd "$current_path" || exit 5
  fi
  assert_repo_is_cloned "$github_username" "$repo_name" "$SSL4TOR_DIR"
}

assert_repo_is_cloned() {
  local target_directory="$1"
  local github_username="$2"
  local github_repository="$3"

  # Assert the repository is cloned.
  if [[ ! -d "$target_directory" ]]; then
    echo "Error, GitHub repository:$github_username/$github_repository is not cloned."
    exit 5
  fi
}
