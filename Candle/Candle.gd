extends Sprite2D

@onready var fire = $Fire

var id = 0
var belongs_to = 0
var contested_by_p1 = false
var contested_by_p2 = false

func _ready():
	update_fire_color()

func update_fire_color():
	if belongs_to == -1:
		fire.modulate = Color(0, 0, 0)
	elif belongs_to == 0:
		fire.modulate = Color(255, 255, 255)
	elif belongs_to == 1:
		fire.modulate = Color(255, 0, 0)
	elif belongs_to == 2:
		fire.modulate = Color(0, 0, 255)

func _on_area_2d_body_entered(body):
	if body.id == 1:
		contested_by_p1 = true
		if contested_by_p2:
			belongs_to = -1
		else:
			belongs_to = 1
	elif body.id == 2:
		contested_by_p2 = true
		if contested_by_p1:
			belongs_to = -1
		else:
			belongs_to = 2
	update_fire_color()

func _on_area_2d_body_exited(body):
	if body.id == 1:
		contested_by_p1 = false
		if contested_by_p2:
			belongs_to = 2
	elif body.id == 2:
		contested_by_p2 = false
		if contested_by_p1:
			belongs_to = 1
	update_fire_color()
	
	
