class_name Player
extends CharacterBody2D


const WALL_BREAK_COMPONENT = preload("res://components/wall_break_component.tscn")
const HEAVY_COMPONENT = preload("res://components/heavy_component.tscn")


enum Component {
	DOUBLE_JUMP,
	SHRINK,
	WALL_BREAK,
	HEAVY
}


@export var color : Color = Color.WHITE : set = set_color
@export var player_index : int = 0


@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var shell_sprite: AnimatedSprite2D = $BodySprite/ShellSprite
@onready var camera_2d: Camera2D = $Camera2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_component: JumpComponent = $JumpComponent


var components : Array[Component] = [] : set = set_components

var spawn_point := Vector2.ZERO


func _ready() -> void:
	_update_body_color()
	if is_multiplayer_authority():
		camera_2d.make_current()


func set_color(value : Color) -> void:
	if color == value:
		return
	color = value
	if is_node_ready():
		_update_body_color()


func _update_body_color() -> void:
	body_sprite.self_modulate = color

@rpc("any_peer", "reliable", "call_remote")
func set_components(new_components : Array[Component]) -> void:
	for c in components:
		_remove_component(c)
	components = new_components
	for c in components:
		_add_component(c)


@rpc("any_peer", "reliable", "call_remote")
func respawn(pos : Vector2 = spawn_point) -> void:
	if not is_multiplayer_authority():
		return
	
	global_position = pos + Vector2.UP * (collision_shape_2d.shape.size.y / 2 - collision_shape_2d.position.y)
	velocity = Vector2.ZERO
	jump_component._double_jump_used = true


func _add_component(component : Component) -> void:
	match component:
		Component.DOUBLE_JUMP:
			var jump : JumpComponent = get_node("JumpComponent")
			jump.double_jump = true
		Component.SHRINK:
			var shrink : ShrinkComponent = ShrinkComponent.new()
			shrink.name = "ShrinkComponent"
			_add_child_component(shrink)
		Component.WALL_BREAK:
			var wall_break : WallBreakComponent = WALL_BREAK_COMPONENT.instantiate()
			_add_child_component(wall_break)
		Component.HEAVY:
			var heavy = HEAVY_COMPONENT.instantiate()
			_add_child_component(heavy)


func _remove_component(component : Component) -> void:
	match component:
		Component.DOUBLE_JUMP:
			var jump : JumpComponent = get_node("JumpComponent")
			jump.double_jump = false
		Component.SHRINK:
			var shrink : ShrinkComponent = get_node("ShrinkComponent")
			shrink.small = false
			shrink.queue_free()
		Component.WALL_BREAK:
			var wall_break : WallBreakComponent = get_node("WallBreakComponent")
			wall_break.queue_free()
		Component.HEAVY:
			var heavy = get_node("HeavyComponent")
			heavy.queue_free()


func _add_child_component(component : Node) -> void:
	add_child(component, true)
	component.owner = self
	component.set_multiplayer_authority(get_multiplayer_authority())
