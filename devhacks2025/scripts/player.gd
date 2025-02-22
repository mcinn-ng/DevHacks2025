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


@onready var body_sprite: AnimatedSprite2D = $BodySprite


var components : Array[Component] = [] : set = set_components


func _enter_tree() -> void:
	if name != "Player":
		set_multiplayer_authority(name.to_int())
		


func _ready() -> void:
	_update_body_color()



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


func _add_component(component : Component) -> void:
		match component:
			Component.DOUBLE_JUMP:
				var jump : JumpComponent = get_node("JumpComponent")
				jump.double_jump = true
			Component.SHRINK:
				var shrink : ShrinkComponent = get_node("ShrinkComponent")
				add_child(shrink, true)
			Component.WALL_BREAK:
				var wall_break : WallBreakComponent = WALL_BREAK_COMPONENT.instantiate()
				add_child(wall_break, true)
			Component.HEAVY:
				var heavy = HEAVY_COMPONENT.instantiate()
				add_child(heavy, true)


func _remove_component(component : Component) -> void:
	match component:
		Component.DOUBLE_JUMP:
			var jump : JumpComponent = get_node("JumpComponent")
			jump.double_jump = false
		Component.SHRINK:
			var shrink : ShrinkComponent = get_node("ShrinkComponent")
			shrink.queue_free()
			pass
		Component.WALL_BREAK:
			var wall_break : WallBreakComponent = get_node("WallBreakComponent")
			wall_break.queue_free()
		Component.HEAVY:
			var heavy = get_node("HeavyComponent")
			heavy.queue_free()
