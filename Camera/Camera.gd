extends Camera2D

var minZoom : float = 0.5
var maxZoom : float = 0.7
var zoomSpeed : float = 0.05
var panSpeed: float = 0.05
var desiredOffset: Vector2
var desiredZoom: float

func find_max_distance(targets: Dictionary) -> float:
	var max_distance = 0.0
	var node_list = targets.values()

	for i in range(node_list.size()):
		var node1 = node_list[i]
		for j in range(i + 1, node_list.size()):
			var node2 = node_list[j]
			var distance = node1.global_position.distance_to(node2.global_position)
			if distance > max_distance:
				max_distance = distance
	return max_distance

func clamp_camera_bounds(z: float, pos: Vector2):
	var viewport_size = get_viewport_rect().size
	var w = viewport_size.x
	var h = viewport_size.y
	var x = w - w/(2*z)
	var y = h - h/(2*z)
	return Vector2(clamp(pos.x, -x, x), clamp(pos.y, -y, y))
	
func _process(delta):
	if !GameManager.is_online || multiplayer.is_server():
		if GameManager.players.size() == 0:
			return

		desiredOffset = Vector2.ZERO
		for player in GameManager.players.values():
			desiredOffset += player.global_position
		desiredOffset /= (GameManager.players.size() + 1)

		var maxDistance = find_max_distance(GameManager.players)
		desiredZoom = clamp(1.0 / (maxDistance / 300.0), minZoom, maxZoom)

		desiredOffset = clamp_camera_bounds(desiredZoom, desiredOffset)
	offset = offset.lerp(desiredOffset, panSpeed)

	zoom = zoom.lerp(Vector2(desiredZoom, desiredZoom), zoomSpeed)
	
	
