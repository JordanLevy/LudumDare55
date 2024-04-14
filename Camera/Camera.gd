extends Camera2D

var minZoom : float = 0.5 # Minimum zoom level
var maxZoom : float = 1.0 # Maximum zoom level
var zoomSpeed : float = 0.05 # Zoom speed
var panSpeed: float = 0.05

func find_max_distance(targets: Dictionary) -> float:
	var max_distance = 0.0

	# Get the values (Node2D objects) from the dictionary
	var node_list = targets.values()

	# Iterate through each pair of nodes
	for i in range(node_list.size()):
		var node1 = node_list[i]
		for j in range(i + 1, node_list.size()):
			var node2 = node_list[j]

			# Calculate the distance between the two nodes
			var distance = node1.global_position.distance_to(node2.global_position)

			# Update max_distance if needed
			if distance > max_distance:
				max_distance = distance

	return max_distance

func _process(delta):
	# If no players are connected, do nothing
	if GameManager.players.size() == 0:
		return

	# Calculate center position between players
	var center = Vector2.ZERO
	for player in GameManager.players.values():
		center += player.global_position
	center /= (GameManager.num_players + 1)

	# Calculate distance between players
	var maxDistance = find_max_distance(GameManager.players)

	# Smoothly move camera towards the center position
	position = position.lerp(center, panSpeed)

	# Calculate zoom level based on distance between players
	var desiredZoom = clamp(1.0 / (maxDistance / 300.0), minZoom, maxZoom)

	# Smoothly adjust zoom level
	zoom = zoom.lerp(Vector2(desiredZoom, desiredZoom), zoomSpeed)
