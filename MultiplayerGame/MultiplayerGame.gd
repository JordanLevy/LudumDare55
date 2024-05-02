extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

@onready var local_game_scene = preload("res://LocalGame/LocalGame.tscn")

var ip = "localhost"
var port = 7000

@export var player_scene: PackedScene
		
func _ready():
	var args = Array(OS.get_cmdline_args())
	print("args: " + str(args))
	if args.has("-s"):
		print("loading server...")
		startServer()
	else:
		pass
		#print("loading client...")
		#startClient()
		
func startServer():
	print("Starting server...")
	
	multiplayer.peer_connected.connect(self._on_client_connected)
	multiplayer.peer_disconnected.connect(self._on_client_disconnected)
	
	# Create server
	var server = ENetMultiplayerPeer.new()
	server.create_server(port, 2)
	multiplayer.multiplayer_peer = server
	start_game()
	
func startClient():
	multiplayer.connected_to_server.connect(self.connected_to_server)
	multiplayer.server_disconnected.connect(self.disconnected_from_server)
	
	print("Creating client...")
	
	# Create client
	var client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client
	start_game()
	
	
# Only called from Clients
@rpc("any_peer")
func send_message_to_server(message: String):
	# the is_server check here is likely unnecessary because we marked it as any_peer
	if multiplayer.is_server():
		print("Message received on server: " + message)
		#send_message_to_client.rpc("Right back at ya! Client. Count:" + str(messageCountFromClient))
		
# Only called from Server
@rpc("authority")
func send_message_to_client(message: String):
	print("Message received on client: " + message)
	
# client callbacks
func connected_to_server():
	print("Connected to server...")
	
func disconnected_from_server():
	print("disconnected from server...")
	
	
# server callbacks
func _on_client_connected(clientId):
	print("Client connected: " + str(clientId))
	
func _on_client_disconnected(clientId):
	print("Client disconnected: " + str(clientId))
	
# UI
func _send_message_to_server():
	print("Sending message to server...")
	send_message_to_server.rpc("Hello from client: " + str(multiplayer.get_unique_id()))
	
func start_game():
	main_menu.hide()
	hud.show()
	if multiplayer.is_server():
		print("load level")
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)

func _on_host_pressed():
	startServer()

func _on_join_pressed():
	startClient()

func add_player(id: int):
	print("add player ", id)
	var player = player_scene.instantiate()
	player.id = 1
	player.name = str(id)
	player.velocity = Vector2.ZERO
	player.position = Vector2.ZERO
	GameManager.num_players += 1
	add_child(player, true)
	GameManager.players[player.id] = player
	if not multiplayer.is_server():
		print(id, ' ', GameManager.players)

func del_player(id: int):
	print("del player ", id)
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value
	print(health_value)

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

func _on_local_pressed():
	GameManager.is_online = false
	get_tree().get_root().add_child(local_game_scene.instantiate())
	get_tree().get_root().remove_child(get_tree().get_root().get_node("MultiplayerGame"))
	GameManager.pre_round_started.emit()
	
func _on_singleplayer_pressed():
	GameManager.is_online = false
	var scene = local_game_scene.instantiate()
	scene.get_node("Player2").is_cpu = true
	get_tree().get_root().add_child(scene)
	get_tree().get_root().remove_child(get_tree().get_root().get_node("MultiplayerGame"))
	GameManager.pre_round_started.emit()
