cd-(){
    local project_dir
    project_dir=$(_get_project_dir)
#    git_repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -z "$project_dir" ]; then
        echo "Not in git repo."
    else
        cd "${project_dir}" || return 1
    fi
}

_get_project_dir(){
    local git_repo_root
    git_repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -n "$git_repo_root" ]; then
        echo "${git_repo_root}"
        return
    fi
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.idea" ]; then
            echo "$current_dir"
            break
        fi
        current_dir=$(dirname "$current_dir")
    done
}
cd--(){
    local project_dir
    project_dir=$(_get_project_dir)
    if [ -z "$project_dir" ]; then
        echo "Not in git repo."
        return 1
    fi

    parent_project_dir="$(dirname ${project_dir})"

    if [ -d "${parent_project_dir}/.idea" ]; then
        cd  "$parent_project_dir" || return 1
    fi





}