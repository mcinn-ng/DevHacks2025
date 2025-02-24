extends Node

const RICH_ERROR_COLOR := "red3"
const RICH_INFO_COLOR := "dodger_blue"

const CMD_QUICKSTART := "quickstart"
const QUICKSTART_AS_CLIENT := "client"
const QUICKSTART_AS_HOST := "host"

const CMD_DEBUG_ADDRESSS := "address" 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args := parse_command_line_arguments()
	for key in args.keys():
		handle_command(key, args[key])


func handle_command(cmd : String, args : String) -> void:
	var handled := false
	match cmd:
		CMD_QUICKSTART:
			handled = handle_quickstart(args)
		CMD_DEBUG_ADDRESSS:
			handled = handle_address(args)
		# INFO:
			# Add more arguments as seen above if desired
		
		_:
			if not (cmd.begins_with("res") and cmd.ends_with(".tscn")):
				print_error("Invalid command line option \"%s\" (--%s%s" % [cmd, cmd, ")" if (not args) or args.is_empty() else "=%s)" % args])
			return
	
	if not handled:
		if args and not args.is_empty():
			print_error("Invalid command line argument \"%s\" (--%s=%s)" % [args, cmd, args])
		else:
			print_error("No args specified for command line option (--%s)" % cmd)


func handle_quickstart(arg_value : String) -> bool:
	match arg_value:
		QUICKSTART_AS_CLIENT:
			print_info("quickstarting as client")
			get_tree().change_scene_to_file.call_deferred("res://menu_screens/session_connect.tscn")
		QUICKSTART_AS_HOST:
			print_info("quickstarting as host")
			get_tree().change_scene_to_file.call_deferred("res://menu_screens/session_host.tscn")
		_:
			return false
	return true


func handle_address(address : String) -> bool:
	if address != "localhost" and not address.is_valid_ip_address():
		return false
	MultiplayerManager.client_default_address = address
	print_info("client default address set to \"%s\"" % address)
	return true


func parse_command_line_arguments() -> Dictionary:
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""
	return arguments


func print_info(info : String) -> void:
	print_rich("[color=%s]cmd: [/color]" % RICH_INFO_COLOR, info)


func print_error(error : String) -> void:
	print_rich("[color=%s]cmd: [/color]" % RICH_ERROR_COLOR, error)
