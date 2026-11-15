extends CharacterBody2D

signal jumped
signal landed
signal respawned
signal stats_changed(deaths: int, coins: int)
signal won

@export var speed_bonus: float = 8.0
@export var dash_speed: float = 850.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.7
var facing: float = 1.0
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var air_jump_available: bool = false
var deaths: int = 0
var coins: int = 0
var has_won: bool = false
var respawn_protection: float = 0.0

@export var speed: float = 220.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -380.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var short_hop_factor: float = 0.45

@onready var camera: Camera2D = $Camera2D
var spawn_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	spawn_position = global_position
	deaths = RunState.deaths
	coins = RunState.coins

var _gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0
var _was_on_floor: bool = false

func _physics_process(delta: float) -> void:
	respawn_protection = maxf(0.0, respawn_protection - delta)
	if global_position.y > 900.0:
		die()
		return
	if Input.is_action_just_pressed("restart"):
		respawn()

	dash_cooldown_left = maxf(0.0, dash_cooldown_left - delta)
	var input_direction: float = Input.get_axis("move_left", "move_right")
	if input_direction != 0.0:
		facing = signf(input_direction)
		$Sprite2D.flip_h = facing < 0.0
	if RunState.dash and Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0.0:
		RunState.dashes += 1
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown
	if dash_time_left > 0.0:
		dash_time_left -= delta
		velocity = Vector2(facing * dash_speed, 0.0)
		move_and_slide()
		return

	var on_floor: bool = is_on_floor()
	if on_floor:
		air_jump_available = true
		_coyote_timer = coyote_time
	else:
		velocity.y += _gravity * delta
		_coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		_buffer_timer = jump_buffer_time
	else:
		_buffer_timer -= delta

	if _buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_buffer_timer = 0.0
		_coyote_timer = 0.0
		RunState.jumps += 1
		jumped.emit()
	elif _buffer_timer > 0.0 and RunState.double_jump and air_jump_available:
		velocity.y = jump_velocity
		air_jump_available = false
		_buffer_timer = 0.0
		RunState.jumps += 1
		jumped.emit()

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= short_hop_factor

	var direction: float = Input.get_axis("move_left", "move_right")
	if absf(direction) > 0.01:
		velocity.x = move_toward(velocity.x, direction * (speed + speed_bonus * RunState.speed_upgrades), acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

	var landed_now: bool = is_on_floor()
	if landed_now and not _was_on_floor:
		landed.emit()
	_was_on_floor = landed_now

func die() -> void:
	if has_won or respawn_protection > 0.0:
		return
	RunState.deaths += 1
	RunState.grant_random_upgrade()
	deaths = RunState.deaths
	stats_changed.emit(deaths, coins)
	respawn()

func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_buffer_timer = 0.0
	respawn_protection = 0.25
	dash_time_left = 0.0
	dash_cooldown_left = 0.0
	air_jump_available = false
	camera.reset_smoothing()
	respawned.emit()

func collect_coin() -> void:
	if has_won:
		return
	RunState.coins += 1
	coins = RunState.coins
	stats_changed.emit(deaths, coins)

func finish_level() -> void:
	if has_won:
		return
	has_won = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	won.emit()
