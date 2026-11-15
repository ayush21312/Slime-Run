extends "res://level_object.gd"

@export var spin_speed: float = 3.5

func _process(delta: float) -> void:
	$Sprite2D.rotation += spin_speed * delta
