extends Label

func _ready():
	pass
 
func format_mmss(total_seconds: float) -> String:
	var minutes: int = int(total_seconds / 60)
	var seconds: int = int(int(total_seconds) % 60)
	var centiseconds = (total_seconds - int(floor(total_seconds))) * 100
	var mmss_string: String = "%02d:%02d:%02d" % [minutes, seconds, centiseconds]
	return mmss_string

func _process(delta):
	if GameManager.game_state == GameManager.GameState.MENU:
		return
	var time_remaining = GameManager.timer_end - Time.get_unix_time_from_system()
	var formatted_time = ""
	if time_remaining <= 0:
		time_remaining = 0
		GameManager.countdown_started.emit()
	elif time_remaining <= GameManager.ROUND_END_DURATION:
		formatted_time = "round_end"
		GameManager.round_ended.emit()
	elif time_remaining <= GameManager.ROUND_DURATION + GameManager.ROUND_END_DURATION:
		formatted_time = "playing"
		time_remaining -= GameManager.ROUND_END_DURATION
		GameManager.round_started.emit()
	elif time_remaining <= GameManager.COUNTDOWN_DURATION + GameManager.ROUND_DURATION + GameManager.ROUND_END_DURATION:
		formatted_time = "countdown"
		time_remaining -= GameManager.ROUND_DURATION + GameManager.ROUND_END_DURATION
	
	#formatted_time = format_mmss(time_remaining)
	text = formatted_time + " " + format_mmss(time_remaining)
