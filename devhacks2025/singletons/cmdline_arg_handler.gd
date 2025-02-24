extends Node

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
			push_error("Invalid command line option \"%s\" (--%s=%s)" % [cmd, cmd, args])
			return
	
	if not handled:
		push_error("Invalid command line argument \"%s\" (--%s=%s)" % [args, cmd, args])


func handle_quickstart(arg_value : String) -> bool:
	match arg_value:
		QUICKSTART_AS_CLIENT:
			print("cmd: quickstarting as client")
			get_tree().change_scene_to_file.call_deferred("res://menu_screens/session_connect.tscn")
		QUICKSTART_AS_HOST:
			print("cmd: quickstarting as host")
			get_tree().change_scene_to_file.call_deferred("res://menu_screens/session_host.tscn")
		_:
			return false
	return true


func handle_address(address : String) -> bool:
	if address != "localhost" and not address.is_valid_ip_address():
		return false
	MultiplayerManager.client_default_address = address
	print("cmd: client default address set to \"%s\"" % address)
	return true

func parse_command_line_arguments() -> Dictionary:
	var arguments := {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	return arguments
