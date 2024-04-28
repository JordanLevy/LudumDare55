extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var connection_code = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/ConnectionCode
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

@onready var local_game_scene = preload("res://LocalGame/LocalGame.tscn")

const PORT = 8080
@export var player_scene: PackedScene
		
func _ready():
	pass

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	start_game()
	
func start_game():
	main_menu.hide()
	hud.show()
	if multiplayer.is_server():
		print("load level")
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)

func _on_join_pressed():
	var ip = "127.0.0.1"
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	start_game()

func add_player(id: int):
	print("add player ", id)
	var player = player_scene.instantiate()
	player.id = id
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
