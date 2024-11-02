# 1. 功能

以下实现了 Git 批量操作脚本，可以针对某个目录下的所有 Git 本地仓库进行快速批量操作

不依赖 Git 外的额外环境

支持在任意目录使用对应命令

支持 TAB 键补全命令与参数

目前支持功能如下：

```
批量 pull
显示本地仓库当前分支
显示本地仓库所有分支
删除本地仓库除当前分支及 master 分支之外的所有其他分支
批量切换到指定关键字对应分支；若本地无对应分支则从远程拉取并切换
切换单个本地仓库到指定关键字对应分支
将指定分支合并到远程仓库的 master 分支，并创建 TAG
检查远程仓库指定关键字对应分支未合并进来的其他分支
在 Windows 环境下打开 Git 本地仓库的 TortoiseGit Revision graph 窗口
在 Windows 环境下关闭 TortoiseGit Revision graph 窗口
```

# 2. 环境要求

- Windows

在 Windows 环境下，需要安装 Git for Windows，以使用 Git Bash 环境

假如需要使用 TortoiseGit 的 Revision graph 功能以图形方式显示分支的树形结构，则需要安装 TortoiseGit

假如需要使 TortoiseGit 的 Revision graph 能够快速打开，可参考 [https://blog.csdn.net/a82514921/article/details/143453869](https://blog.csdn.net/a82514921/article/details/143453869)

- Linux

在 Linux 类环境下，需要安装 Git

# 3. 安装方式

从 [https://github.com/Adrninistrator/git_batch_shell](https://github.com/Adrninistrator/git_batch_shell) 或 [https://gitee.com/adrninistrator/git_batch_shell](https://gitee.com/adrninistrator/git_batch_shell) 下载 git_batch_shell.sh 到任意目录

Windows 环境下，在保存以上 git_batch_shell.sh 脚本文件的目录空白处点击鼠标右键，点击 “Open Git Bash Here”，打开 Git Bash 窗口

执行 sh git_batch_shell.sh install 或 sh git_batch_shell.sh 命令进行安装

Windows 环境下，由于 \~/.bashrc、\~/.bash_profile 等文件默认不存在，因此在安装命令中创建了以上文件，可以自动安装

Linux 类环境下，由于以上文件存在，不能直接覆盖，因此需要按照提示人工在 \~/.bash_profile 或 \~/.bashrc 等文件中增加对应的内容

` 在当前 Windows 环境的 Git Bash 或 Linux 类环境的 bash 窗口执行 . ~/.bashrc 命令，或者重新打开 Git Bash/bash，可以使 gitbatch 命令生效 `

完成以上安装操作后，可在 Git Bash/bash 任意位置执行 gitbatch 命令

# 4. 使用说明

` 输入 gitb 后可以按 TAB 键补全 gitbatch 命令 `

` 输入 gitbatch 后再按两次 TAB 键，可以输出支持的参数 `

所有的操作（除 install、help 外）都是对当前目录下的 Git 本地仓库批量执行

例如目录 parent_dir 中有子目录 git_rep1、git_rep2 等 Git 本地仓库，则需要进入 parent_dir 目录，执行 gitbatch 命令，会依次操作 git_rep1、git_rep2 等 Git 本地仓库

以下为 gitbatch 命令支持通过参数 1 执行的操作

## 4.1. 需要指定分支名称关键字的操作

对于以下需要指定分支名称关键字的操作，会处理包含指定关键字分支的 Git 仓库。假如某个 Git 仓库没有包含指定关键字的分支，则不进行对应操作

例如 Git 仓库 git_rep1 中有分支 git_rep1_2024.11.02，git_rep2 中有分支 git_rep2_2024.11.02，则可以通过共同的关键字 2024.11.02 进行批量操作

假如某个 Git 仓库存在多个分支包含相同的关键字，则脚本不会进行处理

在以上情况下，可以通过 `$` 指定关键字后缀匹配，例如有分支 branch_2024.10.30、branch_2024.10.30_hotfix，都存在关键字 2024.10.30，若需要处理分支 branch_2024.10.30，则指定分支名称关键字时需要在最后指定 `$`，例如 `2024.10.30$`

## 4.2. install

安装脚本，执行 sh 脚本时支持当前参数

## 4.3. help

显示使用说明

## 4.4. pull

批量 pull

## 4.5. branch

显示本地仓库当前分支

## 4.6. branch_all

显示本地仓库所有分支

## 4.7. rm_branch

删除本地仓库除当前分支及 master 分支之外的所有其他分支

## 4.8. checkout

批量切换到指定关键字对应分支；若本地无对应分支则从远程拉取并切换

参数 2 指定分支名称关键字

假如 Git 本地仓库 需要 checkout 名称包含 2024.11.02 关键字的分支，则执行命令 gitbatch checkout 2024.11.02

假如需要 checkout master 分支，则执行命令 gitbatch checkout master

## 4.9. single_checkout

切换单个本地仓库到指定关键字对应分支

参数 2 指定需要切换的仓库目录名称

参数 3 指定分支名称关键字

某些情况下只需要 checkout 单个 Git 本地仓库 ，则可使用当前命令

假如需要将本地仓库 git_rep1 checkout master 分支，则执行命令 gitbatch single_checkout git_rep1 master

## 4.10. merge_master_create_tag

将指定分支合并到远程仓库的 master 分支，并创建 TAG

参数 2 指定分支名称关键字

假如需要将远程仓库名称包含 2024.11.02 关键字的分支合并到 master 分支并创建 TAG，则执行命令 gitbatch merge_master_create_tag 2024.11.02

需要对远程仓库的 master 分支有 push 权限，否则本地 master 分支合并后无法推送到远程仓库

创建的 TAG 名称为 tag_{分支名称}

## 4.11. check_branch_merge

检查远程仓库指定关键字对应分支未合并进来的其他分支

参数 2 指定分支名称关键字

假如需要检查远程仓库名称包含 2024.11.02 关键字的分支有哪些未合并进来的分支，则执行命令 gitbatch check_branch_merge 2024.11.02

假如需要检查 master 分支，则执行命令 gitbatch check_branch_merge master

在安装有 TortoiseGit 的 Windows 环境，会打开 TortoiseGit Revision graph 窗口

检查结果会写入 txt 文件，Windows 环境下会使用 notepad 打开，示例如下：

```log
当前目录 /d
当前时间 Sat Nov  2 15:43:24     2024

git-test 检查未合并进来的分支 origin/branch_111
git-test origin/branch_111 !!! origin/master 分支未合并
git-test origin/branch_111 未合并进来的分支 origin/HEAD->origin/master
git-test origin/branch_111 未合并进来的分支 origin/branch_222
git-test origin/branch_111 未合并进来的分支 origin/branch_333
git-test origin/branch_111 未合并进来的分支 origin/branch_333_hotfix
git-test origin/branch_111 未合并进来的分支 origin/master
```

## 4.12. tortoisegit_revision_graph

在 Windows 环境下打开 Git 本地仓库的 TortoiseGit Revision graph 窗口

参数 2 指定分支名称关键字，若未指定参数 2 则处理每个子目录的 Git 本地仓库

假如需要为名称包含 2024.11.02 关键字的分支对应的本地仓库打开 TortoiseGit Revision graph 窗口，则执行命令 gitbatch tortoisegit_revision_graph 2024.11.02

假如需要为当前目录所有本地仓库打开 TortoiseGit Revision graph 窗口，则执行命令 gitbatch tortoisegit_revision_graph

## 4.13. close_tortoisegit_revision_graph

在 Windows 环境下关闭 TortoiseGit Revision graph 窗口

# 5. 其他脚本

## 5.1. Windows 环境下 pull 本地仓库

假如需要在 Windows 环境下 pull 当前目录的全部本地仓库，可将以下内容保存为 git_pull_all.bat 脚本后执行

不需要打开 Git Bash 就可以执行，更加方便

```bat
@echo off
for /d %%d in (*) do (
    echo %%d
    cd /d "%%d"
    if exist ".git" (
        git branch
        git pull
    ) else (
        echo %%d is not a git repository
    )
	echo.
    cd ..
)
pause
```
