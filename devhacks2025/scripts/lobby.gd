extends Node2D


signal start_pressed


@onready var start_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/QuitButton
@onready var control: Control = $CanvasLayer/Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not MultiplayerManager.is_server():
		start_button.hide()


func _on_start_button_pressed() -> void:
	start_pressed.emit()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/main_menu.tscn")
	MultiplayerManager.disconnect_session()
