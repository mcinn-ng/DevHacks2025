extends Node2D


const LOBBY_INDEX : int = 0


@export var levels : Array[String] = [
	"res://scenes/lobby.tscn",
	"res://scenes/the_main_level.tscn"
]


@onready var level_spawner: MultiplayerSpawner = $LevelSpawner
@onready var player_spawner: PlayerSpawner = $PlayerSpawner


var _current_level : Node


func _ready() -> void:
	level_spawner.spawn_function = _spawn_level
	
	if MultiplayerManager.is_server():
		switch_to_level(LOBBY_INDEX)


func switch_to_level(level_index : int) -> Error:
	if level_index < 0 or level_index > levels.size():
		push_error("Attempted to switch to invalid level index: %d" % level_index)
		return ERR_INVALID_PARAMETER
	
	if is_multiplayer_authority() and _current_level:
		_current_level.queue_free()
	
	var level := level_spawner.spawn(levels[level_index])
	_current_level = level
	
	return OK


#don't use this function. Use the `spawn()` function instead
func _spawn_level(data : String) -> Node:
	var level : Node = load(data).instantiate()
	
	if level.has_node("SpawnPoint"):
		player_spawner.player_spawn_point = level.get_node("SpawnPoint").position
	if level.has_node("LevelProperties"):
		player_spawner.player_components = level.get_node("LevelProperties")._components
	
	return level
