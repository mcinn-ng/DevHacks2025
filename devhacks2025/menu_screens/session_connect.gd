extends Control


@onready var session_id_field: LineEdit = $VBoxContainer/session_id_field


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_connect_button_pressed() -> void:
	var host_address := session_id_field.get_text()
	var error := MultiplayerManager.connect_to_host(host_address)
	if error == OK:
		get_tree().change_scene_to_file("res://scenes/game_area.tscn")
	else:
		push_error("Failed to connect to host (%s): %s" % [host_address, error_string(error)])
		


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/connection_screen.tscn")
