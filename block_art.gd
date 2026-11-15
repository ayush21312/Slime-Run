@tool
extends StaticBody2D

@export_enum("Left", "Middle", "Right") var block_style: int = 1:
	set(value):
		block_style = value
		if is_node_ready():
			_update_art()

const TEXTURES: Array[Texture2D] = [
	preload("res://art/LeftBlock.tres"),
	preload("res://art/MiddleBlock.tres"),
	preload("res://art/RightBlock.tres")
]

func _ready() -> void:
	_update_art()

func _update_art() -> void:
	var sprite: Sprite2D = $Sprite2D
	sprite.texture = TEXTURES[clampi(block_style, 0, 2)]
	sprite.scale = Vector2(64.0 / sprite.texture.get_width(), 64.0 / sprite.texture.get_height())
