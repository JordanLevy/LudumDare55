extends Line2D

@export var radius = 400
@export var candle_scene: PackedScene
@onready var label = $Label

var candles: Array
var candle_offset = Vector2(0, -10)

var connection_code = ""

func _ready():
	GameManager.waiting_for_opponent.connect(_on_waiting_for_opponent)
	GameManager.pre_round_started.connect(_on_pre_round_started)
	GameManager.round_started.connect(_on_round_started)
	GameManager.post_round_started.connect(_on_post_round_started)
	GameManager.connection_code_changed.connect(_on_connection_code_changed)
	var offset = Vector2.ZERO
	clear_points()
	var children = get_children()
	var pentagram_angles = [5*PI/10, 13*PI/10, PI/10, 9*PI/10, 17*PI/10, 5*PI/10]
	for i in range(5):
		var angle = pentagram_angles[i]
		var point = Vector2(cos(angle), -sin(angle)) * radius + offset
		add_point(point)
		var candle = candle_scene.instantiate()
		candle.position = point + candle_offset
		candle.id = i
		add_child(candle)
		candles.append(candle)
		
	var num_circle_points = 30
	for i in range(num_circle_points + 1):
		var angle = PI/2 + i * TAU / num_circle_points
		var point = Vector2(cos(angle), -sin(angle)) * radius + offset
		add_point(point)

func all_players_inside_circle(players: Dictionary):
	var players_list = players.values()
	for player in players_list:
		if player.position.length() > radius - 50:
			return false
	return true
	
func all_players_outside_circle(players: Dictionary):
	var players_list = players.values()
	for player in players_list:
		if player.position.length() < radius + 100:
			return false
	return true

func _process(delta):
	if GameManager.players.size() < 2:
		return
	if GameManager.game_state == GameManager.GameState.PRE_ROUND and all_players_inside_circle(GameManager.players):
		GameManager.round_started.emit()
	elif GameManager.game_state == GameManager.GameState.POST_ROUND and all_players_outside_circle(GameManager.players):
		GameManager.pre_round_started.emit()

func _on_connection_code_changed(code):
	connection_code = code
	if GameManager.game_state == GameManager.GameState.WAITING:
		label.text = "Waiting for opponent to join...\nRitual ID:\n" + connection_code

func _on_waiting_for_opponent():
	label.text = "Waiting for opponent to join...\nRitual ID:\n" + connection_code

func _on_pre_round_started():
	for candle in candles:
		GameManager.candle_lit.emit(candle.id, 0, false)
	self_modulate = Color(1, 1, 1, 1)
	label.self_modulate = Color(1, 1, 1, 1)
	label.text = "Both players must stand in the circle to begin the ritual"
	
func _on_round_started():
	label.text = ""

func _on_post_round_started(winner: int):
	for candle in candles:
		GameManager.candle_lit.emit(candle.id, winner, false)
	if winner == 1:
		self_modulate = Color(255, 0, 0)
		label.self_modulate = Color(255, 0, 0)
		label.text = "Red wins!\nBoth players must exit the circle to reset"
	elif winner == 2:
		self_modulate = Color(0, 0, 255)
		label.self_modulate = Color(0, 0, 255)
		label.text = "Blue wins!\nBoth players must exit the circle to reset"
