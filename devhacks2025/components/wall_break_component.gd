class_name WallBreakComponent
extends Node

signal wall_entered_area
signal wall_exited_area

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _nearby_walls : Array[BreakableWall] = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("break_wall"):
		break_walls.rpc_id(MultiplayerManager.DEFAULT_HOST_ID)


@rpc("authority", "call_remote", "reliable")
func break_walls() -> bool:
	if _nearby_walls.is_empty():
		return false
	
	for wall in _nearby_walls:
		wall.destroy()
	
	_nearby_walls.clear()
	
	return true


func _on_body_entered(body: Node2D) -> void:
	if body is BreakableWall:
		_nearby_walls.append(body)
		wall_entered_area.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is BreakableWall:
		_nearby_walls.erase(body)
		wall_exited_area.emit()
