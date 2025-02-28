extends Node2D


@onready var level_spawner: LevelSpawner = $LevelSpawner
@onready var player_spawner: PlayerSpawner = $PlayerSpawner


func _ready() -> void:
	if MultiplayerManager.is_server():
		level_spawner.switch_to_level(LevelSpawner.LOBBY_INDEX)
		
		level_spawner.get_current_level().start_pressed.connect(_on_lobby_start_button_pressed)
	else:
		Util.connect_to_signal(MultiplayerManager.server_disconnected, _on_server_disconnected)


func _exit_tree() -> void:
	Util.disconnect_from_signal(MultiplayerManager.server_disconnected, _on_server_disconnected)


func _on_lobby_start_button_pressed() -> void:
	level_spawner.switch_to_level(1)


func _on_server_disconnected() -> void:
	NotificationOverlay.fade_in_then_out("Server disconnected.")
	await NotificationOverlay.overlay_maximized
	get_tree().change_scene_to_file("res://menu_screens/session_connect.tscn")
