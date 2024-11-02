#!/bin/bash
# https://github.com/Adrninistrator/git_batch_shell

declare -A ARG_MAP
ARG_KEYS=()

function init_args() {
    local key="$1"
    local value="$2"
    ARG_MAP["$key"]="$value"
    ARG_KEYS+=("$key")
}

init_args "@notice-1" "当前脚本用于在执行命令的目录中的 Git 仓库中进行批量处理"
init_args "@notice-2" "指定分支名称关键字的参数时，假如某关键字存在于多个分支名称中，可以通过 '关键字$' 的形式指定后缀匹配"
init_args "install" "安装脚本，执行 sh 脚本时支持"
init_args "help" "显示使用说明"
init_args "pull" "批量 pull"
init_args "branch" "显示本地仓库当前分支"
init_args "branch_all" "显示本地仓库所有分支"
init_args "rm_branch" "删除本地仓库除当前分支及 master 分支之外的所有其他分支"
init_args "checkout" "批量切换到本地分支；若本地无对应分支则从远程拉取并切换。参数2 指定分支名称关键字"
init_args "single_checkout" "切换单个本地仓库到本地分支。参数2 指定需要切换的仓库目录名称，参数3 指定分支名称关键字"
init_args "merge_master_create_tag" "将指定分支合并到远程仓库的 master 分支，并创建 TAG 。参数2 指定分支名称关键字"
init_args "check_branch_merge" "检查远程仓库指定分支未合并进来的其他分支。参数2 指定分支名称关键字"
init_args "tortoisegit_revision_graph" "在 Windows 环境下打开仓库的 TortoiseGit Revision Graph 窗口。参数2 指定分支名称关键字，若未指定参数2 则处理每个子目录的 Git 仓库"
init_args "close_tortoisegit_revision_graph" "在 Windows 环境下关闭 TortoiseGit Revision Graph 窗口"

INSTALLED_FLAG=~/.git_batch_shell.installed
GIT_BATCH_COMMAND=gitbatch

WINDOWS_FLAG=0
if [[ "$OSTYPE" == "msys" ]]; then
    WINDOWS_FLAG=1
fi

install () {
    for key in "${ARG_KEYS[@]}"; do
        if [[ ! $key == @* ]]; then
            options+="$key "
        fi
    done
    echo "支持的参数 ${options}"

    shell_file=$(basename "$0")
    echo "当前脚本文件名 ${shell_file}"
    if [ ! -f $shell_file ]; then
        echo "未找到脚本文件，请不要使用 ${GIT_BATCH_COMMAND} 命令进行安装"
        return
    fi
    
    cp $shell_file ~/.$shell_file
        
    if [[ $WINDOWS_FLAG -eq 1 ]]; then
        echo "Windows环境，执行安装操作"
        echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' > ~/.bash_profile
        
        echo "${GIT_BATCH_COMMAND}() {
            sh ~/.$shell_file \"\$@\"
        }" > ~/.bashrc
        echo "complete -W \""$options"\" ${GIT_BATCH_COMMAND}" >> ~/.bashrc
        echo "后续可以在任意目录使用 ${GIT_BATCH_COMMAND} 命令，支持按 TAB 键补全命令参数"
        echo -e "\n!!!需要执行 . ~/.bashrc 命令或重新打开 Git Bash 以生效"
        touch $INSTALLED_FLAG
    else
        echo -e "Linux环境，需要人工完成安装操作，需要在 ~/.bash_profile 或 ~/.bashrc 中写入以下内容:\n"
        echo "${GIT_BATCH_COMMAND}() {
            sh ~/.$shell_file \"\$@\"
        }"
        echo "complete -W \""$options"\" ${GIT_BATCH_COMMAND}"
    fi
}

help () {
    echo "- 说明:"
    for key in "${ARG_KEYS[@]}"; do
        if [[ $key == @* ]]; then
            value="${ARG_MAP[$key]}"
            echo "* ${value}"
        fi
    done
    echo -e "\n- 使用的参数1 及作用如下:\n"
    for key in "${ARG_KEYS[@]}"; do
        if [[ ! $key == @* ]]; then
            value="${ARG_MAP[$key]}"
            echo "[ ${key} ] ${value}"
        fi
    done
}

pull () {
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        branch=$(git branch | grep '* ' | awk '{print $2}')
        echo "pull 仓库 ${dir_name} 当前分支 ${branch}"
        git pull
        cd ..
    done
}

branch () {
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        branch=$(git branch | grep '* ' | awk '{print $2}')
        echo "仓库 ${dir_name} 当前分支 ${branch}"
        cd ..
    done
}

branch_all () {
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        echo "仓库 ${dir_name} 本地分支如下:"
        git branch
        echo ""
        cd ..
    done
}

rm_branch () {
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        for branch in $(git branch | grep -v '*' | grep -v 'master' | tr -d ' '); do
            echo "${dir_name} 删除本地分支 ${branch}"
            git branch -d ${branch}
        done
        git branch
        echo ""
        cd ..
    done
}

checkout () {
    branch_keyword=$1
    if [[ "$branch_keyword" == "" ]]; then
        echo "未在参数1指定分支名称关键字"
        return
    fi

    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        echo "处理 Git 仓库目录 ${dir_name}"
        checkout_common
        cd ..
    done
}

single_checkout () {
    dir_name=$1
    if [[ "$dir_name" == "" ]]; then
        echo "未在参数1指定需要切换的仓库目录名称"
        return
    fi

    if [ ! -d $dir_name ]; then
        echo "${dir_name} 目录不存在"
        return
    fi
    if [ ! -d $dir_name/.git ]; then
        echo "${dir_name} 目录未找到 .git 目录，可能不是 Git 仓库目录"
        return
    fi
    
    branch_keyword=$2
    if [[ "$branch_keyword" == "" ]]; then
        echo "未在参数2指定分支名称关键字"
        return
    fi

    cd $dir_name
    echo "处理 Git 仓库目录 ${dir_name}"
    checkout_common
    cd ..
}

checkout_common() {
    git pull
    get_branch_by_keyword $branch_keyword
    if [[ $? -eq 0 ]]; then   
        local_branch_num=$(git branch | tr -d '* ' | grep -P "^${GIT_BATCH_BRANCH_NAME}$" | wc -l)
        if [[ $local_branch_num -eq 0 ]]; then
            git checkout -b $GIT_BATCH_BRANCH_NAME origin/$GIT_BATCH_BRANCH_NAME
        else
            git checkout $GIT_BATCH_BRANCH_NAME
            git pull
        fi    
    fi
}

merge_master_create_tag () {
    echo "需要对远程仓库的 master 分支有 push 权限，否则本地 master 分支合并后无法推送到远程仓库"
    branch_keyword=$1
    if [[ "$branch_keyword" == "" ]]; then
        echo "未在参数1指定分支名称关键字"
        return
    fi

    branch_not_found_reps=()
    push_fail_reps=()
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        echo "处理 Git 仓库目录 ${dir_name}"
        git pull
        get_branch_by_keyword $branch_keyword
        if [[ $? -eq 0 ]]; then
            local_master_num=$(git branch | tr -d '* ' | grep -P "^master$" | wc -l)
            if [[ $local_master_num -eq 0 ]]; then
                git checkout -b master origin/master
            fi
            git checkout master
            git pull origin master
            git merge-base --is-ancestor origin/${GIT_BATCH_BRANCH_NAME} origin/master
            if [[ $? -eq 0 ]]; then
                echo "origin/${GIT_BATCH_BRANCH_NAME} 分支已经合并到master分支"
            else
                echo "origin/${GIT_BATCH_BRANCH_NAME} 分支需要合并到master分支"
                git merge origin/${GIT_BATCH_BRANCH_NAME}
                git push origin master
                if [[ ! $? -eq 0 ]]; then
                    push_fail_reps+=("${dir_name}")
                fi
            fi
            tag_name="tag_${GIT_BATCH_BRANCH_NAME}"
            remote_tag_num=$(git ls-remote --tags origin | grep -P "${tag_name}$" | wc -l)
            if [[ $remote_tag_num -gt 0 ]]; then
                echo "${tag_name} tag 已存在"
            else
                echo "${tag_name} tag 需要创建"
                local_tag_num=$(git tag | grep -P "^${tag_name}$" | wc -l)
                if [[ $local_tag_num -gt 0 ]]; then
                    git tag -d ${tag_name}
                fi
                git tag -a ${tag_name} -m "${tag_name}"
                git push origin ${tag_name}
            fi
            echo ""
        else
            branch_not_found_reps+=("${dir_name}")
        fi
        cd ..
    done

    echo ""
    for branch_not_found_rep in "${branch_not_found_reps[@]}"; do
        echo "!!! 根据关键字未找到或找到多个分支的项目: $branch_not_found_rep"
    done
    echo ""
    for push_fail_rep in "${push_fail_reps[@]}"; do
        echo "!!! push失败的项目，可能因为远程仓库 master 分支不允许push: $push_fail_rep"
    done
}

check_branch_merge () {
    branch_keyword=$1
    if [[ "$branch_keyword" == "" ]]; then
        echo "未在参数1指定分支名称关键字"
        return
    fi

    check_exist_tortoisegitproc
    RESULT_DIR=~/.git_batch_check_branch_merge_result
    [ -d $RESULT_DIR ] || mkdir -p $RESULT_DIR
    dir_hash=$(echo "$(pwd)@${branch_keyword}" | md5sum | awk '{print $1}')
    RESULT="${RESULT_DIR}/${dir_hash}.txt"
    echo 
    echo "当前目录 $(pwd)" > $RESULT
    echo -e "当前时间 $(date)\n" >> $RESULT
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        echo "处理 Git 仓库目录 ${dir_name}"
        git pull
        get_branch_by_keyword $branch_keyword
        if [[ $? -eq 0 ]]; then   
            echo "${dir_name} 检查未合并的分支 origin/${GIT_BATCH_BRANCH_NAME}" >> $RESULT 
            no_merged_branches=$(git branch -r --no-merged origin/${GIT_BATCH_BRANCH_NAME} | tr -d ' ')
            echo "${dir_name} origin/${GIT_BATCH_BRANCH_NAME} 未合并的分支 ${no_merged_branches}"
            master_not_merged=$(echo $no_merged_branches | grep 'origin/master' | wc -l)
            if [[ $master_not_merged -gt 0 ]]; then
                echo "${dir_name} origin/${GIT_BATCH_BRANCH_NAME} master分支未合并" >> $RESULT 
            fi
            for no_merged_branch in $no_merged_branches
            do
                echo "${dir_name} origin/${GIT_BATCH_BRANCH_NAME} 未合并的分支 $no_merged_branch" >> $RESULT 
            done
            open_tortoisegit_revisiongraph $dir_name
        else
            echo "$dir_name 根据关键字未找到或存在多个分支 ${branch_keyword} origin/${GIT_BATCH_BRANCH_NAME}" >> $RESULT
        fi
        echo ""
        echo "" >> $RESULT
        cd ..
    done
    echo -e "\n处理完毕，以下为处理结果 ${RESULT} : \n"
    cat $RESULT
    if [[ $WINDOWS_FLAG -eq 1 ]]; then
        notepad.exe $(realpath $RESULT) &
    fi
}

tortoisegit_revision_graph () {
    if [[ ! $WINDOWS_FLAG -eq 1 ]]; then
        echo "当前功能只支持 Windows 环境"
        return
    fi
    branch_keyword=$1
    if [[ "$branch_keyword" == "" ]]; then
        echo "处理每个子目录的 Git 仓库"
    else
        echo "处理存在指定关键字分支的 Git 仓库"
    fi
    check_exist_tortoisegitproc
    for dir in $(find . -maxdepth 1 -type d); do
        if [ ! -d $dir/.git ]; then
            continue
        fi
        cd $dir
        dir_name=$(echo $dir | awk -F './' '{print $2}')
        echo "处理 Git 仓库目录 ${dir_name}"
        git pull
        if [[ "$branch_keyword" == "" ]]; then
            open_tortoisegit_revisiongraph $dir_name
        else
            get_branch_by_keyword $branch_keyword
            if [[ $? -eq 0 ]]; then
                open_tortoisegit_revisiongraph $dir_name
            fi
        fi
    done
}

close_tortoisegit_revision_graph () {
    if [[ ! $WINDOWS_FLAG -eq 1 ]]; then
        echo "当前功能只支持 Windows 环境"
        return
    fi
    ps -ef | grep TortoiseGitProc | grep -v grep | awk '{print $2}' | xargs -i kill -9 {}
}

get_branch_by_keyword () {
    branch_keyword=$1
    echo "分支名称关键字 ${branch_keyword}"
    
    branch_num=$(git branch -r | grep -v 'origin/HEAD' | grep -P "$branch_keyword" | wc -l)
    if [[ $branch_num -eq 0 ]]; then
        echo "未找到包含关键字的分支 ${branch_keyword}"
        return 1
    fi
    if [[ $branch_num -gt 1 ]]; then
        git branch -r | grep -P "$branch_keyword"
        echo "找到多个包含关键字的分支，请将关键字参数使用前缀（在前面加上^）或后缀方式（在后面加上$）"
        export GIT_BATCH_BRANCH_NAME="$(git branch -r | grep -P "$branch_keyword" | tr -d "\n")"
        return 1
    fi
    branch=$(git branch -r | grep -v 'origin/HEAD' | grep -P "$branch_keyword" | awk -F 'origin/' '{print $2}')
    echo "通过关键字找到分支 ${branch}"
    export GIT_BATCH_BRANCH_NAME="$branch"
    return 0
}

open_tortoisegit_revisiongraph () {
    dir_name=$1
    full_path=$(realpath dir_name)
    if [[ $WINDOWS_FLAG -eq 1 ]]; then
        TortoiseGitProc.exe /command:revisiongraph /path:\"$full_path\" &
    fi
}

check_exist_tortoisegitproc () {
    which TortoiseGitProc.exe > /dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        echo "环境变量中未找到 TortoiseGitProc.exe ，请将 TortoiseGit 安装目录的 bin 目录路径添加到 PATH 环境变量中"
    fi
}

# 入口
if [[ $# -eq 0 ]]; then
    if [[ ! -f $INSTALLED_FLAG ]]; then
        install
        exit 0
    fi
    help
    exit 0
fi

case "$1" in
    install)
        install
        ;;
    help)
        help
        ;;
    pull)
        pull
        ;;
    branch)
        branch
        ;;
    branch_all)
        branch_all
        ;;
    rm_branch)
        rm_branch
        ;;
    checkout)
        checkout $2
        ;;
    single_checkout)
        single_checkout $2 $3
        ;;
    merge_master_create_tag)
        merge_master_create_tag $2
        ;;
    check_branch_merge)
        check_branch_merge $2
        ;;
    tortoisegit_revision_graph)
        tortoisegit_revision_graph $2
        ;;
    close_tortoisegit_revision_graph)
        close_tortoisegit_revision_graph
        ;;
    *)
    echo "未知参数: $1"
    ;;
esac