extends Node2D

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var trail: Line2D = $Trail
@onready var poof: CPUParticles2D = $Poof
var points: Array[Vector2] = []
var ages: Array[float] = []
var emit_timer: float = 0.0
var fall_speed: float = 0.0
var poof_count: int = 0

func _ready() -> void:
	global_position = Vector2.ZERO
	player.connect("landed", _on_landed)
	player.connect("respawned", _on_respawned)

func _process(delta: float) -> void:
	emit_timer -= delta
	if player.velocity.y > 0.0:
		fall_speed = player.velocity.y
	for index: int in range(ages.size()):
		ages[index] += delta
	while not ages.is_empty() and ages[0] > 0.22:
		ages.remove_at(0)
		points.remove_at(0)
	if player.velocity.length() > 40.0 and emit_timer <= 0.0:
		points.append(to_local(player.global_position + Vector2(0, 8)))
		ages.append(0.0)
		emit_timer = 0.016
	trail.points = PackedVector2Array(points)

func _on_landed() -> void:
	if fall_speed > 150.0:
		_emit_poof()
	fall_speed = 0.0

func _on_respawned() -> void:
	points.clear()
	ages.clear()
	trail.clear_points()
	fall_speed = 0.0
	_emit_poof()

func _emit_poof() -> void:
	poof.position = to_local(player.global_position + Vector2(0, 16))
	poof.restart()
	poof.emitting = true
	poof_count += 1
