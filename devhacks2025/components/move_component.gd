class_name MoveComponent
extends Node


const DEFAULT_SPEED : float = 300.0


@export var speed : float = DEFAULT_SPEED
@export var player : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if MultiplayerManager.is_session_active() and not is_multiplayer_authority():
		return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		player.velocity.x = direction * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
