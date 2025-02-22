extends Node2D


signal start_pressed


@onready var start_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CanvasLayer/Control/HBoxContainer/VBoxContainer/QuitButton
@onready var control: Control = $CanvasLayer/Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not MultiplayerManager.hosting:
		start_button.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_pressed.emit()


func _on_quit_button_pressed() -> void:
	MultiplayerManager.disconnect_session()
	get_tree().change_scene_to_file("res://menu_screens/main_menu.tscn")

@rpc("any_peer", "reliable")
func hide_ui() -> void:
	control.hide()
