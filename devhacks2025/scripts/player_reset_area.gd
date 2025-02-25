@tool
class_name PositionResetArea
extends Area2D

## A marker indicating the position or height to reset objects objects that enter the area to
@export var reset_marker : Marker2D : set = set_reset_marker
## If set to true, objects will only have their y coordinate updated when reset
@export var adaptive_horizontal_position : bool = true


func _ready() -> void:
	update_configuration_warnings()


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if not body.is_multiplayer_authority():
		return
	
	if not (body is Player or body is CharacterBody2D or body is RigidBody2D):
		return
	
	var reset_position : Vector2
	if adaptive_horizontal_position:
		reset_position = Vector2(body.global_position.x, reset_marker.global_position.y)
	else:
		reset_position = reset_marker.global_position
	
	if body is Player:
		body.respawn(reset_position)
	else:
		body.global_position = reset_position


func set_reset_marker(marker : Marker2D) -> void:
	reset_marker = marker
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not reset_marker:
		warnings.append("A reset marker is required.")
	
	return warnings
