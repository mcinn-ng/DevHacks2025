class_name ApplyForcesComponent
extends Node


@export var player : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()
	
	process_physics_priority = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	player.move_and_slide()
