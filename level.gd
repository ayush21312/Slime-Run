extends Node2D

@export var level_number: int = 1
@export_file("*.tscn") var next_level: String = "res://level_2.tscn"
@onready var tracker: Label = $HUD/TrackerMargin/Tracker
@onready var timer_label: Label = $HUD/TrackerMargin/Timer
@onready var upgrades_label: Label = $HUD/UpgradesMargin/Upgrades
@onready var level_label: Label = $HUD/Instructions/LevelLabel

func _ready() -> void:
	RunState.start_level()
	level_label.text = "LEVEL %d" % level_number
	_on_stats_changed(RunState.deaths, RunState.coins)

func _process(_delta: float) -> void:
	timer_label.text = "Time: " + RunState.format_time(RunState.elapsed_time)

func _on_stats_changed(deaths: int, coins: int) -> void:
	tracker.text = "Deaths: %d   Blobs: %d" % [deaths, coins]
	upgrades_label.text = "Upgrades: " + RunState.upgrade_text()

func _on_player_won() -> void:
	call_deferred("_go_to_next_level")

func _go_to_next_level() -> void:
	RunState.complete_level()
	if level_number == 3:
		RunState.timer_running = false
		next_level = "res://statistics.tscn"
	var error: Error = get_tree().change_scene_to_file(next_level)
	if error != OK:
		push_error("Could not load next level: " + next_level)
