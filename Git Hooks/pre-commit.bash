#!/usr/bin/env bash
# Git pre-commit hook for validating HTML markup conformness
# 林博仁 © 2016

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
declare -r PROGRAM_FILENAME="$(basename "$0")"
declare -r PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
declare -r PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
declare -r PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

## Unofficial Bash Script Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
# 將未定義的變數的參考視為錯誤
set -u

# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
# 林博仁：因為不知為何「git diff --name-only --cached | grep --extended-regexp '.(htm|html|xhtml)$' &>/dev/null」命令即使後方有 if 語句仍然會中斷程式所以暫時停用
# set -e

# If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

# Check what to diff against, HEAD not exist in
# if git rev-parse --verify HEAD >/dev/null 2>&1
# then
# 	against=HEAD
# else
# 	# Initial commit: diff against an empty tree object
# 	against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
# fi

# Redirect output to stderr.
#exec 1>&2

# 檢查新修訂版準備區域中有無 (X)HTML 檔案，如果有的話就傳給 HTML Tidy 進行標記語法檢查
git diff --name-only --cached | grep --extended-regexp '.(htm|html|xhtml)$' &>/dev/null
if [ $? -eq 0 ]; then
	printf "新修訂版提交前掛勾程式：正在檢查 (X)HTML 標記語法……\n"
	git diff --name-only --cached | grep --extended-regexp '.(htm|html|xhtml)$' | xargs --verbose --max-args=1 tidy -config "來源碼美化器設定檔/HTML.validate.tidyrc"
	if [ $? -ne 0 ];then
		printf "新修訂版提交前掛勾程式：錯誤：語法檢查失敗！\n" 1>&2
		printf "新修訂版提交前掛勾程式：錯誤：提交程序將被中止。\n"
		exit 1
	else
		printf "新修訂版提交前掛勾程式：語法檢查通過。\n"
		exit 0
	fi
else
	exit 0
fi

# 不應該運行到這裡
