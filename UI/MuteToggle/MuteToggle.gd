extends TextureButton

func _on_toggled(toggled_on: bool):
	GameManager.mute_toggled.emit(toggled_on)
