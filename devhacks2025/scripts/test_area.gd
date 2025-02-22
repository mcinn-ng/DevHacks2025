extends Node2D


const PLAYER = preload("res://scenes/player.tscn")


@onready var control: Control = $CanvasLayer/Control
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var line_edit: LineEdit = $CanvasLayer/Control/LineEdit
@onready var host_address_edit: LineEdit = $CanvasLayer/Control/VBoxContainer/HBoxContainer/LineEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_button_pressed() -> void:
	control.hide()
	MultiplayerManager.setup_server()
	multiplayer.peer_connected.connect(_on_peer_connected)
	_on_peer_connected(multiplayer.get_unique_id())


func _on_connect_button_pressed() -> void:
	var error := MultiplayerManager.connect_to_host(host_address_edit.text)
	if error == OK:
		control.hide()


func _on_peer_connected(id : int) -> void:
	var player = PLAYER.instantiate()
	player.name = str(id)
	player.position = spawn_point.position
	add_child.call_deferred(player, true)
