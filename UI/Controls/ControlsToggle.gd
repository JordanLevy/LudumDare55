extends TextureButton

@export var key_icon: Texture2D
@export var control_icon: Texture2D
@onready var p1_icon = $TextureRect
@onready var p2_icon = $TextureRect2

func _on_pressed():
	var new_controls = GameManager.controls + 1
	if new_controls >= 3:
		new_controls -= 3
	GameManager.controls_changed.emit(new_controls)
	if GameManager.mapping_p1[new_controls] == '_key':
		p1_icon.texture = key_icon
	else:
		p1_icon.texture = control_icon
	if GameManager.mapping_p2[new_controls] == '_key':
		p2_icon.texture = key_icon
	else:
		p2_icon.texture = control_icon
