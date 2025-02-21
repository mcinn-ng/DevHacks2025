extends Node


@export var player : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.move_and_slide()
