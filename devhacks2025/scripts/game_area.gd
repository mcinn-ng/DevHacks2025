extends Node2D


@onready var level_spawner: LevelSpawner = $LevelSpawner
@onready var player_spawner: PlayerSpawner = $PlayerSpawner


func _ready() -> void:
	if MultiplayerManager.is_server():
		level_spawner.switch_to_level(LevelSpawner.LOBBY_INDEX)
		
		level_spawner.get_current_level().start_pressed.connect(_on_lobby_start_button_pressed)


func _on_lobby_start_button_pressed() -> void:
	level_spawner.switch_to_level(1)
