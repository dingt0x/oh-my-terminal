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

    local target
    if [ -d "${parent_project_dir}/.idea" ]; then
        target="$parent_project_dir"
    else
        target=${project_dir}
    fi

    cd  "$target" || return 1

    return 1
}

cd0(){
    local project_dir
    project_dir=$(_get_project_dir)
    if [ -z "$project_dir" ]; then
        echo "Not in git repo."
        return 1
    fi

    parent_project_dir="$(dirname ${project_dir})"

    local real_project_dir
    if [ -d "${parent_project_dir}/.idea" ]; then
        real_project_dir="$parent_project_dir"
    else
        real_project_dir=${project_dir}
    fi

    target="$(find "${real_project_dir}" -mindepth 1 -maxdepth 1 -type d  ! -name '.*'  |sort | head -1 |tail -1)"
    if [ -n "$target" ] && [ -d "${target}/.idea" ] || [ -d "${target}/.git" ] ; then
        cd $target || return 1
    else
        echo "Project not found"
    fi
    return 1
}

cd1(){
    local project_dir
    project_dir=$(_get_project_dir)
    if [ -z "$project_dir" ]; then
        echo "Not in git repo."
        return 1
    fi

    parent_project_dir="$(dirname ${project_dir})"

    local real_project_dir
    if [ -d "${parent_project_dir}/.idea" ]; then
        real_project_dir="$parent_project_dir"
    else
        real_project_dir=${project_dir}
    fi

    target="$(find "${real_project_dir}" -mindepth 1 -maxdepth 1 -type d  ! -name '.*'  |sort | head -2 | tail -1)"
    if [ -n "$target" ] && [ -d "${target}/.idea" ] || [ -d "${target}/.git" ] ; then
        cd $target || return 1
    else
        echo "Project not found"
    fi
    return 1
}

cd2(){
    local project_dir
    project_dir=$(_get_project_dir)
    if [ -z "$project_dir" ]; then
        echo "Not in git repo."
        return 1
    fi

    parent_project_dir="$(dirname ${project_dir})"

    local real_project_dir
    if [ -d "${parent_project_dir}/.idea" ]; then
        real_project_dir="$parent_project_dir"
    else
        real_project_dir=${project_dir}
    fi

    target="$(find "${real_project_dir}" -mindepth 1 -maxdepth 1 -type d  ! -name '.*'  |sort | head -3 | tail -1)"
    if [ -n "$target" ] && [ -d "${target}/.idea" ] || [ -d "${target}/.git" ] ; then
        cd $target || return 1
    else
        echo "Project not found"
    fi
    return 1
}