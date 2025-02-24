extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LogicMap.modulate.a = 0  # Set transparency to 0 (fully invisible)
