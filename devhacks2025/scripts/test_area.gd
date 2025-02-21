extends Node2D


const PLAYER = preload("res://scenes/player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_button_pressed() -> void:
	MultiplayerManager.setup_server()
	multiplayer.peer_connected.connect(_on_peer_connected)
	_on_peer_connected(multiplayer.get_unique_id())


func _on_connect_button_pressed() -> void:
	MultiplayerManager.connect_to_host("localhost")


func _on_peer_connected(id : int) -> void:
	var player = PLAYER.instantiate()
	player.name = str(id)
	add_child(player, true)
