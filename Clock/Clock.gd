extends Label

func _ready():
	pass
 
func format_mmss(total_seconds: float) -> String:
	var minutes: int = int(total_seconds / 60)
	var seconds: int = int(int(total_seconds) % 60)
	var mmss_string: String = "%02d:%02d" % [minutes, seconds]
	return mmss_string

func _process(delta):
	var time_remaining = GameManager.timer_end - Time.get_unix_time_from_system()
	var formatted_time = ""
	if GameManager.game_state == GameManager.GameState.MENU:
		formatted_time = ""
	elif GameManager.game_state == GameManager.GameState.COUNTDOWN:
		if time_remaining <= 0:
			time_remaining = 0
			GameManager.round_started.emit()
		formatted_time = str(int(ceil(time_remaining)))
	elif GameManager.game_state == GameManager.GameState.PLAYING:
		if time_remaining <= 0:
			time_remaining = 0
			#GameManager.round_ended.emit()
		formatted_time = format_mmss(time_remaining)
	elif GameManager.game_state == GameManager.GameState.ROUND_OVER:
		pass
	text = formatted_time
