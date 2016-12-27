#!/usr/bin/env bash
# 拉入最新版本網站.cgi - 從 GitHub 拉入最新版本網站內容的 CGI 程式
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

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
set -e

# If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

######## File scope variable definitions ended ########

######## Included files ########

######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	# Run the job in background by calling it itself
	if [ $PROGRAM_ARGUMENT_ORIGINAL_NUMBER -eq 0 ]; then
		# CGI programming: the HTTP response header
		printf "Content-type: text/plain; charset=utf-8\r\n\r\n";

		printf "\n"
		printf "==== Webhook 前景程式於 $(date) 被執行 ====\n"
		printf "啟動 Webhook 背景程式。\n"
		sudo -g web-admin "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}" the_argument >/dev/null &
		disown
		printf "==== Webhook 前景程式於 $(date) 結束 ====\n"
		exit 0
	else
		printf "\n" &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		printf "==== Webhook 背景程式於 $(date) 被執行 ====\n" &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		# version control - How to force "git pull" to overwrite local files? - Stack Overflow
		# http://stackoverflow.com/questions/1125968/how-to-force-git-pull-to-overwrite-local-files
		git fetch --all &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		git clean -d -x -f &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		git reset --hard origin/master &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		git lfs pull origin &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		printf "==== Webhook 背景程式結束 ====\n" &>> "${PROGRAM_DIRECTORY}/${PROGRAM_FILENAME}.background.log"
		exit 0
	fi

}
main
######## Program ended ########
