extends Node

var deaths: int = 0
var coins: int = 0
var double_jump: bool = false
var dash: bool = false
var speed_upgrades: int = 0
var upgrades: Array[String] = []

var deaths_since_ability: int = 0
var next_ability_after: int = randi_range(2, 3)

func grant_random_upgrade() -> void:
	speed_upgrades += 1
	upgrades.append("Speed Increase")
	deaths_since_ability += 1
	if deaths_since_ability < next_ability_after:
		return
	deaths_since_ability = 0
	next_ability_after = randi_range(2, 3)
	var choices: Array[String] = []
	if not double_jump:
		choices.append("Double Jump")
	if not dash:
		choices.append("Dash")
	if choices.is_empty():
		return
	var chosen: String = choices[randi_range(0, choices.size() - 1)]
	if chosen == "Double Jump":
		double_jump = true
	else:
		dash = true
	upgrades.append(chosen)

func upgrade_text() -> String:
	var names: PackedStringArray = []
	for upgrade: String in upgrades:
		if upgrade == "Speed Increase":
			if not names.has("Speed Increase x%d" % speed_upgrades):
				names.append("Speed Increase x%d" % speed_upgrades)
		elif not names.has(upgrade):
			names.append(upgrade)
	return ", ".join(names) if not names.is_empty() else "None"

var elapsed_time: float = 0.0
var level_time: float = 0.0
var timer_running: bool = false
var jumps: int = 0
var dashes: int = 0
var completed_levels: int = 0
var level_times: Array[float] = []
var level_deaths: Array[int] = []
var level_blobs: Array[int] = []
var starting_deaths: int = 0
var starting_coins: int = 0

func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		level_time += delta

func start_level() -> void:
	level_time = 0.0
	starting_deaths = deaths
	starting_coins = coins
	timer_running = true

func complete_level() -> void:
	level_times.append(level_time)
	level_deaths.append(deaths - starting_deaths)
	level_blobs.append(coins - starting_coins)
	completed_levels += 1

func format_time(seconds: float) -> String:
	var whole_seconds: int = int(seconds)
	var minutes: int = int(float(whole_seconds) / 60.0)
	return "%02d:%02d" % [minutes, whole_seconds % 60]

func reset_run() -> void:
	deaths = 0
	coins = 0
	double_jump = false
	dash = false
	speed_upgrades = 0
	deaths_since_ability = 0
	next_ability_after = randi_range(2, 3)
	upgrades.clear()
	elapsed_time = 0.0
	level_time = 0.0
	timer_running = false
	jumps = 0
	dashes = 0
	completed_levels = 0
	level_times.clear()
	level_deaths.clear()
	level_blobs.clear()
	starting_deaths = 0
	starting_coins = 0
