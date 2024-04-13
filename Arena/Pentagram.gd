extends Line2D

@export var radius = 280
@export var candle_scene: PackedScene

var candles: Array
var candle_offset = Vector2(0, -10)

func _ready():
	var offset = Vector2.ZERO
	clear_points()
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
