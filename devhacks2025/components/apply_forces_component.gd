class_name ApplyForcesComponent
extends Node

@export var player : CharacterBody2D
@export var push_force : float = 1000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()
	
	process_physics_priority = 1


# Called every physics frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(_delta: float) -> void:
	if MultiplayerManager.is_session_active() and not is_multiplayer_authority():
		return
	
	if not player.move_and_slide():
		return
	
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var collider : RigidBody2D = collision.get_collider()
			collider.apply_force(collision.get_normal() * -push_force)
