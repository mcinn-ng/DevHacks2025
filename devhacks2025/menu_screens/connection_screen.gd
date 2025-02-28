extends Control


func _on_host_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/session_host.tscn")


func _on_connect_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/session_connect.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/main_menu.tscn")
