extends Control

func _ready() -> void:
	RunState.timer_running = false
	$Center/Rows/Play.grab_focus()

func _on_play_pressed() -> void:
	RunState.reset_run()
	var error: Error = get_tree().change_scene_to_file("res://level_1.tscn")
	if error != OK:
		push_error("Could not start Slime Run.")
