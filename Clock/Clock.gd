extends Label

func _ready():
	pass
 
func _process(delta):
	var time_remaining = GameManager.timer_end - Time.get_unix_time_from_system()
	text = str(time_remaining)
