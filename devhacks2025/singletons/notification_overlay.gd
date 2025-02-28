extends CanvasLayer


signal overlay_maximized
signal overlay_minimized


const DEFAULT_TEXT := "[NO TEXT HAS BEEN SET]"


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var message_label: Label = $Control/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var continue_label: Label = $Control/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueLabel
@onready var control: Control = $Control


var waiting_for_input := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
		message_label.text = DEFAULT_TEXT
		continue_label.text = "Press space to continue..."
		continue_label.hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if visible and waiting_for_input:
		if event.is_action_pressed("overlay_continue"):
			get_viewport().set_input_as_handled()
			waiting_for_input = false
			set_process_input(false)
			await fade_out()
			continue_label.hide()
			print("horray!")


func set_message(text : String) -> void:
	message_label.text = text


func is_active() -> bool:
	return visible and control.modulate.a >= 1


func fade_in_then_wait(message : String, custom_blend : int = -1, custom_speed : int = 1, from_end : bool = false) -> void:
	message_label.text = message
	continue_label.show()
	if not is_active():
		await fade_in(message, custom_blend, custom_speed, from_end)
	waiting_for_input = true
	set_process_input(true)
	await overlay_minimized


func fade_in_then_out_custom(message : String, fade_in_sec : float, hold_sec : float, fade_out_sec : float = fade_in_sec) -> void:
	message_label.text = message
	if is_active():
		await get_tree().create_timer(fade_in_sec).timeout
	else:
		animation_player.play("fade_in", -1, 1 / fade_in_sec)
		await animation_player.animation_finished
	await get_tree().create_timer(hold_sec).timeout
	animation_player.play("fade_out", -1, 1 / fade_out_sec)
	await animation_player.animation_finished


func fade_in_then_out(message : String, custom_blend : int = -1, custom_speed : int = 1, from_end : bool = false) -> Signal:
	message_label.text = message
	animation_player.play("fade_in_then_out", custom_blend, custom_speed, from_end)
	return animation_player.animation_finished


func fade_in(message : String, custom_blend : int = -1, custom_speed : int = 1, from_end : bool = false) -> Signal:
	message_label.text = message
	animation_player.play("fade_in", custom_blend, custom_speed, from_end)
	return animation_player.animation_finished


func fade_out(custom_blend : int = -1, custom_speed : int = 1, from_end : bool = false) -> Signal:
	animation_player.play("fade_out", custom_blend, custom_speed, from_end)
	return animation_player.animation_finished


func _set_waiting_for_input(enabled : bool) -> void:
	waiting_for_input = enabled
