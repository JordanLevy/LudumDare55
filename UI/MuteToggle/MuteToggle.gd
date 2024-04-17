extends TextureButton

func _on_toggled(is_muted: bool):
	GameManager.mute_toggled.emit(is_muted)
