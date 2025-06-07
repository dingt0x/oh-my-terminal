function cd-(){
    local git_repo_root
    git_repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -z "$git_repo_root" ]; then
        echo "Not in git repo."
    else
        cd "${git_repo_root}" || return
    fi
}

