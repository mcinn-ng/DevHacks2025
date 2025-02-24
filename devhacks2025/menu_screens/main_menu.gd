extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/connection_screen.tscn")


func _on_instructions_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/instructions.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
