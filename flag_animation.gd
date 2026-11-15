extends AnimatedSprite2D

var wave_time: float = 0.0
var resting_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	resting_scale = scale
	play("wave")

func _process(delta: float) -> void:
	wave_time += delta * 5.0
	scale.x = resting_scale.x * (1.0 + sin(wave_time) * 0.04)
