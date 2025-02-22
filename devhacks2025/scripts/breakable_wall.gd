class_name BreakableWall
extends StaticBody2D

@rpc("any_peer", "call_remote", "reliable")
func destroy() -> void:
	queue_free()
