extends AudioStreamPlayer

func _ready():
	GameManager.mute_toggled.connect(_on_mute_toggled)

func _on_mute_toggled(toggled_on: bool):
	if toggled_on:
		volume_db = -80
	else:
		volume_db = 0
