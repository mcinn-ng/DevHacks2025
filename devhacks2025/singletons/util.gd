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
