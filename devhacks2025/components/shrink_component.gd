class_name ShrinkComponent
extends Node 


@export var player : CharacterBody2D


var normal_size = Vector2(1.5, 1.5)
var small_size = Vector2(1.5, 0.75)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	shrink()
	pass

func shrink():
	if !is_multiplayer_authority():
		return
	if Input.is_action_pressed("Crawl"):
		player.scale = small_size
	else:
		player.scale = normal_size
