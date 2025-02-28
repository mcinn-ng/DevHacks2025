extends Control


@onready var host_button: Button = $VBoxContainer/HostButton


func _on_host_button_pressed() -> void:
	host_button.disabled = true	
	var error := MultiplayerManager.setup_server()
	if error == OK:
		error = get_tree().change_scene_to_file("res://scenes/game_area.tscn")
		
	if error == OK:
		return
	
	var error_msg := "Failed to start server. (%s - %d)" % [error_string(error), error]
	push_error(error_msg)
	await NotificationOverlay.fade_in_then_wait(error_msg)
	host_button.disabled = false	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/connection_screen.tscn")
