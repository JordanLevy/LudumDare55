extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var connection_code = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/ConnectionCode
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
	var connection_code = connection_code.text
	var address = 'localhost'
	if connection_code != 'localhost':
		var bytes = EncryptionManager.hex_string_to_bytes(connection_code)
		var decrypted = EncryptionManager.decrypt(bytes, EncryptionManager.key)
		address = EncryptionManager.buffer_to_string(decrypted).strip_edges(true, true)
	print('address', address)
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer

func add_player(peer_id):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.velocity = Vector2.ZERO
	player.position = Vector2.ZERO
	GameManager.num_players += 1
	add_child(player)
	if player.is_multiplayer_authority():
		player.id = 1
		player.set_texture()
		player.set_start_position()
		GameManager.waiting_for_opponent.emit()
		player.health_changed.connect(update_health_bar)
		player.health_changed.emit(player.health)
	else:
		player.id = 2
		player.set_texture()
		player.set_start_position()
	GameManager.players[player.id] = player
	if GameManager.num_players == 2:
		GameManager.pre_round_started.emit()

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
	
	var address = upnp.query_external_address()
	address = EncryptionManager.pad_string(address, 16)
	print('address', address, ' ', address.length())
	var encrypted = EncryptionManager.encrypt(address, EncryptionManager.key)
	print('encrypted ', encrypted)
	var connection_code = EncryptionManager.bytes_to_hex_string(encrypted)
	DisplayServer.clipboard_set("Join my Ritual Rumble game!\nUse this Ritual ID.\n" + connection_code)
	print("Success! Join with code: %s" % connection_code)
