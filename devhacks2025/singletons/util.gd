## Home for convenience functions
extends Node


## Connects the signal if it is not already connected
func connect_to_signal(sig : Signal, function : Callable, flags : int = 0) -> void:
	if not sig.is_connected(function):
		sig.connect(function, flags)

## Disconnects the signal if it is connected
func disconnect_from_signal(sig : Signal, function : Callable) -> void:
	if sig.is_connected(function):
		sig.disconnect(function)

## Retrieves the list of keybinds for an action as a string
func get_action_keys_string(action : String) -> String:
	var keys := get_action_keys(action)
	if not keys or keys.is_empty():
		return "[Unbound]"
	var as_string : String = keys.pop_front()
	for key in keys:
		as_string += ", " + key
	return as_string

## Returns the list of keybinds for an action
func get_action_keys(action : String) -> Array[String]:
	var events := InputMap.action_get_events(action)
	var keys : Array[String] = []
	keys.assign(
		events.map(
			func(x : InputEvent) -> String:
				return x.as_text()
				)
	)
	return keys


## Changes the scene to the specified file, or reverts to the main menu if an error occurrs.
## Closes the game if unable to revert to the main menu.
func change_scene_else_return_to_main(path : String) -> Error:
	var error := get_tree().change_scene_to_file(path)
	
	if error != OK:
		await NotificationOverlay.fade_in_then_wait("Error changing scene. (%s - %d)" % [error_string(error), error])
		error = get_tree().change_scene_to_file("res://menu_screens/main_menu.tscn")
		if error != OK:
			await NotificationOverlay.fade_in_then_wait("Error changing scene to main menu. (%s - %d)" % [error_string(error), error])
			get_tree().quit(error)
	
	return error
