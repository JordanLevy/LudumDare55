extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar


const PORT = 9999
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
		
func _ready():
	pass

func _on_host_pressed():
	main_menu.hide()
	hud.show()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	upnp_setup()

func _on_join_pressed():
	main_menu.hide()
	hud.show()
	peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = peer

func add_player(peer_id):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.velocity = Vector2.ZERO
	player.position = Vector2.ZERO
	GameManager.num_players += 1
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		player.health_changed.emit(player.health)
	if GameManager.num_players == 2:
		GameManager.countdown_started.emit()

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value
	print(health_value)

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
