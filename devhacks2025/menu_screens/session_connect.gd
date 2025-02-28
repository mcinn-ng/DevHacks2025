extends Control


@onready var session_id_field: LineEdit = $VBoxContainer/SessionIdField
@onready var connect_button: Button = $VBoxContainer/ConnectButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if MultiplayerManager.client_default_address:
		session_id_field.text = MultiplayerManager.client_default_address



func _on_connect_button_pressed() -> void:
	connect_button.disabled = true
	var host_address := session_id_field.get_text()
	var error := MultiplayerManager.connect_to_host(host_address)
	
	if error == OK:
		NotificationOverlay.fade_in("Connecting to host...")
		_bind_multiplayer_connection_signals(host_address)
		return
	
	_on_connection_failed(host_address, error)


func _bind_multiplayer_connection_signals(host_address : String) -> void:
	Util.connect_to_signal(MultiplayerManager.connected_to_server, _on_connected_to_server)
	Util.connect_to_signal(MultiplayerManager.connection_failed, _on_connection_failed.bind(host_address, ERR_CANT_CONNECT))


func _unbind_multiplayer_connection_signals() -> void:
	Util.disconnect_from_signal(MultiplayerManager.connected_to_server, _on_connected_to_server)
	Util.disconnect_from_signal(MultiplayerManager.connection_failed, _on_connection_failed)


func _on_connected_to_server() -> void:
	_unbind_multiplayer_connection_signals()
	var error := get_tree().change_scene_to_file("res://scenes/game_area.tscn")
	
	if error == OK:
		NotificationOverlay.fade_out()
		return
		
	MultiplayerManager.disconnect_session()
	var error_msg := "Failed to switch to game scene. (%s - %d)" % [error_string(error), error]
	push_error(error_msg)
	await NotificationOverlay.fade_in_then_wait(error_msg)
	connect_button.disabled = false



func _on_connection_failed(host_address : String, error : Error) -> void:
	_unbind_multiplayer_connection_signals()
	var error_msg := "Failed to connect to host: %s (%s - %d)" % [host_address, error_string(error), error]
	push_error(error_msg)
	await NotificationOverlay.fade_in_then_wait(error_msg)
	connect_button.disabled = false


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_screens/connection_screen.tscn")


func _on_advanced_toggle_toggled(toggled_on: bool) -> void:
	session_id_field.visible = toggled_on
