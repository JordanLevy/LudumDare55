extends StaticBody2D

@onready var line: Line2D = $Line2D
var collision_shapes: Array = []

@export var default_collision_layer: int = 3
@export var default_collision_mask: int = 2
var drawing = true
var max_segment_length = 50
var max_points = 10

func add_point_to_line(point: Vector2):
	if line.get_point_count() > max_points:
		drawing = false
		return
	line.add_point(point)
	if line.get_point_count() >= 2:
		var collision_shape = CollisionShape2D.new()
		var segment_shape = SegmentShape2D.new()
		segment_shape.a = line.get_point_position(line.get_point_count() - 2)
		segment_shape.b = line.get_point_position(line.get_point_count() - 1)
		collision_shape.shape = segment_shape
		print(default_collision_layer)
		set_collision_layer_value(default_collision_layer, true)
		set_collision_mask_value(default_collision_mask, true)
		add_child(collision_shape)
		collision_shapes.append(collision_shape)

func update_last_point(new_point: Vector2):
	if not drawing:
		return
	if line.get_point_count() >= 2:
		var distance = (line.get_point_position(line.get_point_count() - 2) - new_point).length()
		if distance > max_segment_length:
			add_point_to_line(new_point)
			return
		if line.get_point_count() > 0:
			line.set_point_position(line.get_point_count() - 1, new_point)
			if collision_shapes.size() > 0:
				var last_collision_shape = collision_shapes[collision_shapes.size() - 1]
				var segment_shape = last_collision_shape.shape as SegmentShape2D
				segment_shape.b = new_point
		
