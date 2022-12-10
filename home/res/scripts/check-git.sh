# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Checks all git repositories in $git_dir and prints outstanding git statuses.

print_usage() {
	echo "USAGE:"
	echo "    $0       -- check repositories in $DEFAULT_DIR"
	echo "    $0 [DIR] -- check repositories in [DIR]"
	exit 1
}

# prints $1 in fancy colour
fancy_print() {
	tput setaf 5 && tput bold
	echo $1
	tput sgr 0
}

# set $git_dir to first argument if present
git_dir=${1:-$git_dir}

# iterate through subdirectories of git_dir
for dir in $(find "$git_dir" -mindepth 1 -maxdepth 1 -type d); do
	# skip non git repos
	[ -d "$dir/.git" ] || continue

	# whether we should print the status
	print_status=0

	# get git status sans errors
	git_status=$(git -C "$dir" status 2> /dev/null)

	# skip if status errored
	if [ $? -ne 0 ]; then
		fancy_print "$dir"
		echo "Git status errored: skipping"
		continue
	fi

	# check for unstaged
	echo $git_status | grep "nothing to commit" > /dev/null
	if [ $? -ne 0 ]; then
		print_status=$((print_status + 1))
	fi

	# check for staged
	echo $git_status | grep "to be committed" > /dev/null
	if [ $? -eq 0 ]; then
		print_status=$((print_status + 1))
	fi

	# check for committed but ahead
	echo $git_status | grep "ahead of" > /dev/null
	if [ $? -eq 0 ]; then
		print_status=$((print_status + 1))
	fi

	# check at least 1 remote
	if [ -z "$(git -C "$dir" remote)" ]; then
		fancy_print "$dir"
		echo "WARNING: $dir has no git remote"
	fi

	# print status if necessary
	if [ "$print_status" -gt 0 ]; then
		fancy_print "$dir"
		git -C "$dir" status

		# set that we have some repos out of date
		out_of_date="yes"
	fi
done

# if no repos are out of date, print happy message
if [ -z $out_of_date ]; then
	echo "All repos in $git_dir committed and pushed"
fi
