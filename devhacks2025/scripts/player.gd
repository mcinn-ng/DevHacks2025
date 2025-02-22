extends CharacterBody2D

var normal_size = Vector2(1.5, 1.5)
var small_size = Vector2(1.5, 0.75)

func shrink():
	if Input.is_action_pressed("Crawl"):
		scale = small_size
	else:
		scale = normal_size

func _physics_process(delta: float) -> void:
	shrink()
