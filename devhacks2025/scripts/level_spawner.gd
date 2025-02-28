@tool
class_name LevelSpawner
extends MultiplayerSpawner


signal level_changed


const LOBBY_INDEX : int = 0

@export var player_spawner : PlayerSpawner : set = set_player_spawner
@export var levels : Array[String] = [
	"res://scenes/lobby.tscn",
	"res://scenes/the_main_level.tscn"
]


var _current_level : Node : get = get_current_level
var _spawn_point : Marker2D : get = get_spawn_point
var _level_components : Array : get = get_level_components


func _init() -> void:
	spawn_function = _spawn_level


func _ready() -> void:
	update_configuration_warnings()


func switch_to_level(level_index : int) -> Error:
	if not is_multiplayer_authority():
		push_error("Caller is not the multiplayer authority.")
		return ERR_UNAUTHORIZED
	
	if level_index < 0 or level_index > levels.size():
		push_error("Attempted to switch to invalid level index: %d" % level_index)
		return ERR_INVALID_PARAMETER
	
	if _current_level:
		_current_level.queue_free()
	
	var level := spawn(levels[level_index])
	_current_level = level
	
	# Only called on the authority/host
	level_changed.emit()
	
	return OK


func get_current_level() -> Node:
	return _current_level


func get_spawn_point() -> Marker2D:
	return _spawn_point


func get_level_components() -> Array:
	return _level_components


func set_player_spawner(spawner : PlayerSpawner) -> void:
	player_spawner = spawner
	update_configuration_warnings()


#don't use this function. Use the `spawn()` function instead
func _spawn_level(data : String) -> Node:
	var level : Node = load(data).instantiate()
	
	if level.has_node("SpawnPoint"):
		_spawn_point = level.get_node("SpawnPoint")
	else:
		_spawn_point = Marker2D.new()
	
	if level.has_node("LevelProperties"):
		_level_components = level.get_node("LevelProperties").get_components()
	else:
		_level_components = []
	
	return level

# Only called on the peers (Not the authority/host)
func _on_spawned(_node: Node) -> void:
	level_changed.emit()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not player_spawner:
		warnings.append("Player spawner has not been set.")
	
	return warnings
