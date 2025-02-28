class_name GravityComponent
extends Node


@export var player : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if MultiplayerManager.is_session_active() and not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
