extends Control

@onready var totals: Label = $Center/Panel/Margin/Rows/Totals
@onready var breakdown: Label = $Center/Panel/Margin/Rows/Breakdown
@onready var upgrades_label: Label = $Center/Panel/Margin/Rows/Upgrades

func _ready() -> void:
	RunState.timer_running = false
	totals.text = "Time: %s     Deaths: %d     Blobs eaten: %d\nLevels: %d / 3     Jumps: %d     Dashes: %d" % [RunState.format_time(RunState.elapsed_time), RunState.deaths, RunState.coins, RunState.completed_levels, RunState.jumps, RunState.dashes]
	var lines: PackedStringArray = []
	for index: int in range(RunState.level_times.size()):
		lines.append("Level %d     %s     %d deaths     %d blobs" % [index + 1, RunState.format_time(RunState.level_times[index]), RunState.level_deaths[index], RunState.level_blobs[index]])
	breakdown.text = "\n".join(lines) if not lines.is_empty() else "Finish the levels to record your statistics."
	upgrades_label.text = "Upgrades earned: %d\n%s" % [RunState.upgrades.size(), RunState.upgrade_text()]
	$Center/Panel/Margin/Rows/PlayAgain.grab_focus()

func _on_play_again_pressed() -> void:
	RunState.reset_run()
	var error: Error = get_tree().change_scene_to_file("res://level_1.tscn")
	if error != OK:
		push_error("Could not restart the game.")
