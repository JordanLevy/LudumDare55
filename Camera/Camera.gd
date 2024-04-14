extends Camera2D

var minZoom : float = 0.5 # Minimum zoom level
var maxZoom : float = 1.0 # Maximum zoom level
var zoomSpeed : float = 0.01 # Zoom speed
var panSpeed: float = 0.01

func _process(delta):
	# If no players are connected, do nothing
	if GameManager.players.size() == 0:
		return

	# Calculate center position between players
	var center = Vector2.ZERO
	for player in GameManager.players.values():
		center += player.global_position
	center /= GameManager.num_players

	# Calculate distance between players
	var maxDistance = 10
	if GameManager.players.has(1) and GameManager.players.has(2):
		maxDistance = GameManager.players[1].global_position.distance_to(GameManager.players[2].global_position)

	# Smoothly move camera towards the center position
	position = position.lerp(center, panSpeed)

	# Calculate zoom level based on distance between players
	var desiredZoom = clamp(1.0 / (maxDistance / 300.0), minZoom, maxZoom)

	# Smoothly adjust zoom level
	zoom = zoom.lerp(Vector2(desiredZoom, desiredZoom), zoomSpeed)
