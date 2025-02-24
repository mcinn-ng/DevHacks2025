extends Control


func _on_host_button_pressed() -> void:
	var error := MultiplayerManager.setup_server()
	if error == OK:
		var tree := get_tree()
		tree.change_scene_to_file("res://scenes/game_area.tscn")
	else:
		push_error("Failed to start server: %s" % [error_string(error)])


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/connection_screen.tscn")
