class_name JumpComponent
extends Node


const DEFAULT_JUMP_VELOCITY = -400.0


@export var jump_velocity : float = DEFAULT_JUMP_VELOCITY 
@export var double_jump : bool = true
@export var player : CharacterBody2D


var _double_jump_used : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Handle jump.
	var on_floor := player.is_on_floor()
	if Input.is_action_just_pressed("ui_accept") and (on_floor or (double_jump and not _double_jump_used)):
		_double_jump_used = not on_floor
		player.velocity.y = DEFAULT_JUMP_VELOCITY
