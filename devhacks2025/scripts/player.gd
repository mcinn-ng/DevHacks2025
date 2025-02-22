extends CharacterBody2D

@export var color : Color = Color.WHITE


@onready var body_sprite: AnimatedSprite2D = $BodySprite


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
