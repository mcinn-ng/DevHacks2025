class_name BreakableWall
extends StaticBody2D


func destroy() -> void:
	queue_free()
