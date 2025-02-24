class_name ShrinkComponent
extends Node 


@export var player : Player : set = set_player

var normal_size : Vector2
var small_size := Vector2(22, 8)
var hitbox_offset := Vector2(0, -1)
var small : bool = false : set = set_small

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player:
		player = get_parent()


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event.is_action("Crawl"):
		set_small.rpc(event.is_pressed())


func set_player(node : Player) -> void:
	player = node
	if player:
		normal_size = player.collision_shape_2d.shape.size

@rpc("authority", "reliable", "call_local")
func set_small(enabled : bool) -> void:
	if small == enabled:
		return
	
	small = enabled
	
	if small:
		player.collision_shape_2d.shape.size = small_size
		player.collision_shape_2d.position += hitbox_offset
		player.body_sprite.play("Shrink")
		player.shell_sprite.play("Shrink")
	else:
		player.collision_shape_2d.shape.size = normal_size
		player.collision_shape_2d.position -= hitbox_offset
		player.body_sprite.play("Snail")
		player.shell_sprite.play("default")
