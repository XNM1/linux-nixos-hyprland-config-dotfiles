# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_ftdv_global_optspecs
	string join \n c/cached w/worktree config= v/verbose h/help V/version
end

function __fish_ftdv_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_ftdv_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_ftdv_using_subcommand
	set -l cmd (__fish_ftdv_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c ftdv -n "__fish_ftdv_needs_command" -l config -d 'Configuration file path' -r
complete -c ftdv -n "__fish_ftdv_needs_command" -s c -l cached -d 'Show staged changes (equivalent to git diff --cached)'
complete -c ftdv -n "__fish_ftdv_needs_command" -s w -l worktree -d 'Show changes in working directory (default)'
complete -c ftdv -n "__fish_ftdv_needs_command" -s v -l verbose -d 'Verbose output'
complete -c ftdv -n "__fish_ftdv_needs_command" -s h -l help -d 'Print help'
complete -c ftdv -n "__fish_ftdv_needs_command" -s V -l version -d 'Print version'
complete -c ftdv -n "__fish_ftdv_needs_command" -a "diff" -d 'Compare git refs, files, or directories'
complete -c ftdv -n "__fish_ftdv_needs_command" -a "status" -d 'Show current git status with diffs'
complete -c ftdv -n "__fish_ftdv_needs_command" -a "completions" -d 'Generate shell completions'
complete -c ftdv -n "__fish_ftdv_needs_command" -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c ftdv -n "__fish_ftdv_using_subcommand diff" -l cached -d 'Show staged changes'
complete -c ftdv -n "__fish_ftdv_using_subcommand diff" -s h -l help -d 'Print help'
complete -c ftdv -n "__fish_ftdv_using_subcommand status" -s h -l help -d 'Print help'
complete -c ftdv -n "__fish_ftdv_using_subcommand completions" -s h -l help -d 'Print help'
complete -c ftdv -n "__fish_ftdv_using_subcommand help; and not __fish_seen_subcommand_from diff status completions help" -f -a "diff" -d 'Compare git refs, files, or directories'
complete -c ftdv -n "__fish_ftdv_using_subcommand help; and not __fish_seen_subcommand_from diff status completions help" -f -a "status" -d 'Show current git status with diffs'
complete -c ftdv -n "__fish_ftdv_using_subcommand help; and not __fish_seen_subcommand_from diff status completions help" -f -a "completions" -d 'Generate shell completions'
complete -c ftdv -n "__fish_ftdv_using_subcommand help; and not __fish_seen_subcommand_from diff status completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
