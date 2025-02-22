extends Node2D


const LOBBY_INDEX : int = 0


@export var levels : Array[String] = [
	"res://scenes/lobby.tscn",
	"res://scenes/the_main_level.tscn"
]


@onready var level_spawner: MultiplayerSpawner = $LevelSpawner
@onready var player_spawner: PlayerSpawner = $PlayerSpawner
@onready var start_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/QuitButton
@onready var control: Control = $CanvasLayer/Control


var _current_level : Node


func _ready() -> void:
	level_spawner.spawn_function = _spawn_level
	
	if MultiplayerManager.hosting:
		switch_to_level(LOBBY_INDEX)
	else:
		start_button.hide()


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
		var id := multiplayer.get_unique_id()
		player_spawner._players[id].player_character.set_components(level.get_node("LevelProperties").get_player_components(player_spawner._players[id].peer_index))
	
	return level




func _on_start_button_pressed() -> void:
	hide_ui.rpc()
	switch_to_level(LOBBY_INDEX + 1)


func _on_quit_button_pressed() -> void:
	MultiplayerManager.disconnect_session()
	get_tree().change_scene_to_file("res://menu_screens/main_menu.tscn")


@rpc("any_peer", "reliable", "call_local")
func hide_ui() -> void:
	control.hide()
