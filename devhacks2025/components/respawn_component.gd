class_name RespawnComponent
extends Node


@export var player : CharacterBody2D
@export var vertical_casting_distance : float = 500
@export_range(1, 256) var max_casting_itterations := 8

@export_flags_2d_physics var casting_mask : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event.is_action_pressed("reset"):
		player.respawn(get_point_on_surface(player.global_position))


func get_point_on_surface(current_global_position : Vector2, max_itterations : int = max_casting_itterations) -> Vector2:
	if max_itterations <= 0:
		push_error("Max itterations cannot be <= 0")
		return current_global_position
	
	var space_state = player.get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result : Dictionary
	var itteration : int = 1
	while not result or result.is_empty():
		var vertical_offset := Vector2(current_global_position.x, -vertical_casting_distance * itteration)
		var query = PhysicsRayQueryParameters2D.create(vertical_offset, current_global_position, casting_mask, [ player.get_rid() ])
		result = space_state.intersect_ray(query)
		if itteration == max_itterations:
			return current_global_position
		itteration += 1
	
	return result.position
