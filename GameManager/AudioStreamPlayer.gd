extends AudioStreamPlayer

func _ready():
	GameManager.mute_toggled.connect(_on_mute_toggled)

func _on_mute_toggled(is_muted: bool):
	if is_muted:
		volume_db = -80
	else:
		volume_db = 0
