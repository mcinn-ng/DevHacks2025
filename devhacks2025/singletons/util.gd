extends Node
# Home for convenience functions


# Avoid checking every time if a function is already connected
func connect_to_signal(sig : Signal, function : Callable, flags : int = 0) -> void:
	if not sig.is_connected(function):
		sig.connect(function, flags)

# Avoid checking every time if a function is actually connected
func disconnect_from_signal(sig : Signal, function : Callable) -> void:
	if sig.is_connected(function):
		sig.disconnect(function)


func get_action_keys_string(action : String) -> String:
	var keys := get_action_keys(action)
	if not keys or keys.is_empty():
		return "[Unbound]"
	var as_string : String = keys.pop_front()
	for key in keys:
		as_string += ", " + key
	return as_string


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
