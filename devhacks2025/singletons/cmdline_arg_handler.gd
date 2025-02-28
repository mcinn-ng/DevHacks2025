extends Node


const CUSTOM_ARG_PREFIX := "++"

const RICH_ERROR_COLOR := "#e74c3c"
const RICH_INFO_COLOR := "dodger_blue"
const RICH_WARNING_COLOR := "#f1c40f"

const CMD_QUICKSTART := "quickstart"
const QUICKSTART_OPTIONS := {
	"client" : "res://menu_screens/session_connect.tscn",
	"host" : "res://menu_screens/session_host.tscn",
	# INFO: extend this to allow hopping to a specific scene on startup
}

const CMD_DEFAULT_ADDRESS := "address" 
const CUSTOM_VALID_ADDRESSES := [
	"localhost",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args := parse_command_line_arguments()
	for key in args.keys():
		handle_command(key.trim_prefix(CUSTOM_ARG_PREFIX), args[key])


func handle_command(cmd : String, args : String) -> void:
	var handled := false
	match cmd:
		CMD_QUICKSTART:
			handled = handle_quickstart(args)
		CMD_DEFAULT_ADDRESS:
			handled = handle_address(args)
		# INFO:
			# Add additional custom flags/options as needed
		_:
			print_error("Invalid command line option \"%s\" (%s%s%s" % [cmd, CUSTOM_ARG_PREFIX, cmd, ")" if (not args) or args.is_empty() else "=%s)" % args])
			return
	
	if not handled:
		if args and not args.is_empty():
			print_error("Invalid command line argument \"%s\" (%s%s=%s)" % [args, CUSTOM_ARG_PREFIX, cmd, args])
		else:
			print_error("No args specified for command line option (%s%s)" % [CUSTOM_ARG_PREFIX, cmd])


func handle_quickstart(arg : String) -> bool:
	if not QUICKSTART_OPTIONS.has(arg):
		return false
	
	# Don't quickstart if not launched normally
	if get_tree().current_scene.name != "MainMenu":
		print_warning("Ignoring quickstart as current scene != MainMenu")
		return true
	
	var scene_path : String = QUICKSTART_OPTIONS[arg]
	var scene
	
	if ResourceLoader.exists(scene_path):
		scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	
	if (not scene) or not (scene is PackedScene):
		print_error("quickstart option is linked to an invalid path: \"%s=%s\"" % [arg, scene_path])
		return true
	
	print_info("quickstart mode: %s" % arg)
	get_tree().change_scene_to_file.call_deferred(scene_path)
	
	return true


func handle_address(address : String) -> bool:
	if not (address in CUSTOM_VALID_ADDRESSES) and not address.is_valid_ip_address():
		return false
	MultiplayerManager.client_default_address = address
	print_info("default address set: %s" % address)
	return true


func parse_command_line_arguments() -> Dictionary:
	var arguments = {}
	var custom_args : Array[String] = get_custom_cmd_line_args()
	for argument in custom_args:
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0]] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument] = ""
	return arguments


func get_custom_cmd_line_args() -> Array[String]:
	var args : Array = Array(OS.get_cmdline_args())
	var custom_args : Array[String] = []
	custom_args.assign(args.filter(is_custom_arg))
	return custom_args


func is_custom_arg(arg : String) -> bool:
	return arg.begins_with(CUSTOM_ARG_PREFIX)


func print_info(info : String) -> void:
	print_with_color(info, RICH_INFO_COLOR)


func print_error(error : String) -> void:
	print_with_color(error, RICH_ERROR_COLOR)


func print_warning(waring : String) -> void:
	print_with_color(waring, RICH_WARNING_COLOR)


func print_with_color(msg : String, rich_color : String) -> void:
	print_rich("[color=%s][cmd] [/color]" % rich_color, msg)
