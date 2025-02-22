extends Node2D


const LOBBY_INDEX : int = 0


@export var levels : Array[String] = [
	"res://scenes/lobby.tscn",
	"res://levels/level_one.tscn"
]


@onready var level_spawner: MultiplayerSpawner = $LevelSpawner
@onready var player_spawner: PlayerSpawner = $PlayerSpawner



func _ready() -> void:
	level_spawner.spawn_function = _spawn_level
	
	if multiplayer.is_server():
		player_spawner.setup_as_host()
		switch_to_level(LOBBY_INDEX)


func switch_to_level(level_index : int) -> Error:
	if level_index < 0 or level_index > levels.size():
		push_error("Attempted to switch to invalid level index: %d" % level_index)
		return ERR_INVALID_PARAMETER
	
	level_spawner.spawn("res://scenes/lobby.tscn")
	return OK


#don't use this function. Use the `spawn()` function instead
func _spawn_level(data : String) -> Node:
	var level : Node = load(data).instantiate()
	
	if level.has_node("SpawnPoint"):
		player_spawner.player_spawn_point = level.get_node("SpawnPoint").position
	
	return level
