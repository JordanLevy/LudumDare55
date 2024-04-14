extends AudioStreamPlayer

func _ready():
	GameManager.mute_toggled.connect(_on_mute_toggled)

func _on_mute_toggled(toggled_on: bool):
	playing = not toggled_on
