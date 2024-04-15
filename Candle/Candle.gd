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

func all_values_equal(list):
	var first_value = null
	for value in list:
		if first_value == null:
			first_value = value
		elif first_value != value:
			return false
	return true

func set_belongs_to(value, check_winner):
	belongs_to = value
	GameManager.candles_belong_to[id] = value
	update_fire_color()
	if not check_winner:
		return
	var first = GameManager.candles_belong_to[0]
	if (first == 1 or first == 2) and all_values_equal(GameManager.candles_belong_to):
		GameManager.post_round_started.emit(first)

func _on_area_2d_body_entered(body):
	if GameManager.game_state != GameManager.GameState.ROUND:
		return
	if body.id == 1:
		contested_by_p1 = true
		if contested_by_p2:
			set_belongs_to(-1, false)
		else:
			set_belongs_to(1, true)
	elif body.id == 2:
		contested_by_p2 = true
		if contested_by_p1:
			set_belongs_to(-1, false)
		else:
			set_belongs_to(2, true)
	update_fire_color()

func _on_area_2d_body_exited(body):
	if GameManager.game_state != GameManager.GameState.ROUND:
		return
	if body.id == 1:
		contested_by_p1 = false
		if contested_by_p2:
			set_belongs_to(2, true)
	elif body.id == 2:
		contested_by_p2 = false
		if contested_by_p1:
			set_belongs_to(1, true)
	update_fire_color()
	
	
