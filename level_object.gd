extends Area2D

@export_enum("Spike", "Coin", "Finish") var object_type: String = "Spike"
var activated: bool = false
@export var bob_height: float = 5.0
@export var bob_speed: float = 2.4
var bob_time: float = 0.0
var bob_origin: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	bob_origin = position
	bob_time = position.x * 0.01

func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("die") or activated:
		return
	match object_type:
		"Spike":
			body.call_deferred("die")
		"Coin":
			activated = true
			body.call("collect_coin")
			hide()
			set_deferred("monitoring", false)
		"Finish":
			activated = true
			body.call("finish_level")

func _process(delta: float) -> void:
	if object_type == "Coin" and not activated:
		bob_time += delta * bob_speed
		position.y = bob_origin.y + sin(bob_time) * bob_height
