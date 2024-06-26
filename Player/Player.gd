extends CharacterBody2D

class_name Player

signal health_changed(health_value)

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var passive_hit_particles = $PassiveHitParticles
@onready var parry_particles = $ParryParticles
@onready var shield_node = $Shield
@export var barrier_scene: PackedScene
var pentagram: Node2D

@export var is_cpu: bool = false
var target_candle: Dictionary = {}
var target_position: Vector2 = Vector2.ZERO
var target_rotation: float = 0.0
const CPU_ROTATION_SPEED: float = 5
var launch_velocity: float = 0.0
@export var id: int = 1
var peer_id: int
var health = 100
const ACCELERATION = 2000
const MAX_SPEED = 500
const FRICTION = 800

var using_gamepad: bool = false
var mouse_position: Vector2 = Vector2.ZERO
var prev_joystick_position: Vector2 = Vector2.ZERO
var rotation_offset = -PI/2

var is_in_hitstun: bool = false;

const PASSIVE_FORCE = 1000
const PASSIVE_FORCE_TRANSFERRED = 1.2
const MIN_FORCE = 1000
const MAX_FORCE = 1500

var last_barrier_point = Vector2.ZERO
var barrier: Node2D

var melee = 'melee'
var special = 'special'
var shield = 'shield'
var left = 'left'
var right = 'right'
var up = 'up'
var down = 'down'
var pause = 'pause'
var opponent: Player

func _enter_tree():
	
	if GameManager.is_online:
		set_multiplayer_authority(str(name).to_int())
	elif id == 1:
		pentagram = get_tree().get_root().get_node("LocalGame/Pentagram")
		opponent = get_tree().get_root().get_node("LocalGame/Player2")
	else:
		pentagram = get_tree().get_root().get_node("LocalGame/Pentagram")
		opponent = get_tree().get_root().get_node("LocalGame/Player1")

@rpc("call_local")
func create_barrier():
	if barrier != null:
		barrier.queue_free()
	barrier = barrier_scene.instantiate()
	if id == 1:
		barrier.default_collision_layer = 3
		barrier.default_collision_mask = 2
		barrier.modulate = Color(1, 0, 0, 1)
	elif id == 2:
		barrier.default_collision_layer = 4
		barrier.default_collision_mask = 1
		barrier.modulate = Color(0, 0, 1, 1)
	get_tree().get_root().add_child(barrier)
	barrier.add_point_to_line(global_position)
	barrier.add_point_to_line(global_position)

@rpc("call_local")
func update_barrier():
	if barrier != null:
		if barrier.line.get_point_count() > 3 and velocity.length() <= 0.05:
			release_barrier()
		else:
			barrier.update_last_point(global_position)
		
@rpc("call_local")
func release_barrier():
	barrier.drawing = false

func _ready():
	GameManager.controls_changed.connect(_on_controls_changed)
	GameManager.controls_changed.emit(0)
	GameManager.round_started.connect(_on_round_start)
	if GameManager.is_online:
		peer_id = multiplayer.get_unique_id()
		GameManager.players[peer_id] = self
		GameManager.peer_ids.append(peer_id)
		GameManager.peer_ids.sort()
		GameManager.player_ports = {}
		for i in range(len(GameManager.peer_ids)):
			GameManager.player_ports[GameManager.peer_ids[i]] = i
		update_port()
	set_texture()
	set_layers()
	set_start_position()
	GameManager.players[id] = self
	if GameManager.is_online and not is_multiplayer_authority(): return

func set_new_target_candle():
	target_candle = pentagram.get_random_target_candle(self)
	if target_candle:
		set_target_position(target_candle["position"])

func _on_round_start():
	if is_cpu:
		set_new_target_candle()

func _on_controls_changed(config):
	var mapping = GameManager.mapping_p1
	if id == 2:
		mapping = GameManager.mapping_p2
	var value = mapping[GameManager.controls]
	if value != '_key':
		using_gamepad = true
	else:
		using_gamepad = false
	if GameManager.is_online:
		using_gamepad = false
		value = '_key'
	melee = 'melee' + value
	special = 'special' + value
	shield = 'shield' + value
	left = 'left' + value
	right = 'right' + value
	up = 'up' + value
	down = 'down' + value
	pause = 'pause' + value

func set_texture():
	if id == 1:
		sprite.texture = load("res://Player/WizardRed.png")
	elif id == 2:
		sprite.texture = load("res://Player/WizardBlue.png")

func set_start_position():
	if id == 1:
		position = Vector2(0, -500)
	elif id == 2:
		position = Vector2(0, 500)
		

func set_layers():
	for i in range(1, 5):
		set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)
		$PassiveHitbox.set_collision_layer_value(i, false)
		$PassiveHitbox.set_collision_mask_value(i, false)
	if id == 1:
		set_collision_layer_value(1, true)
		set_collision_mask_value(4, true)
		$PassiveHitbox.set_collision_layer_value(3, true)
		$PassiveHitbox.set_collision_mask_value(2, true)
	elif id == 2:
		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)
		$PassiveHitbox.set_collision_layer_value(4, true)
		$PassiveHitbox.set_collision_mask_value(1, true)
		
func _unhandled_input(event):
	if GameManager.is_online and not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed(pause):
		get_tree().quit()
	
	if true or GameManager.game_state == GameManager.GameState.ROUND:
		#temporarily disabling barrier in online because it doesn't work
		if Input.is_action_just_pressed(melee) and !is_attacking():
			play_melee_effects.rpc()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
			
		if Input.is_action_just_pressed(special) and !is_attacking():
			play_special_effects.rpc()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
			
		if Input.is_action_just_pressed(shield) and !is_attacking():
			play_shield_effects.rpc()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func is_attacking():
	return anim_player.current_animation == "special"

func update_port():
	if !GameManager.player_ports.has(peer_id):
		return
	id = GameManager.player_ports[peer_id] + 1

func _physics_process(delta):
	#var a = ", ".join(GameManager.peer_ids)
	#var b = ""
	#for i in GameManager.player_ports:
		#b += '{' + str(i) + ':' + str(GameManager.player_ports[i]) + '}, '
	#push_warning(peer_id, ': [', a, ']', '[', b, ']')
	if GameManager.is_online and not is_multiplayer_authority(): return
	
	update_barrier.rpc()
	#print(anim_player.current_animation)
	
	#if GameManager.game_state != GameManager.GameState.PLAYING:
		#return

	var input_dir = Vector2.ZERO
	if is_cpu:
		if GameManager.game_state == GameManager.GameState.PRE_ROUND:
			set_target_position(Vector2(0, 200))
		elif GameManager.game_state == GameManager.GameState.POST_ROUND:
			set_target_position(Vector2(0, 550))
		elif target_candle.size() == 0 or GameManager.candles_belong_to[target_candle["candle"].id] == id:
			set_new_target_candle()
		input_dir = calculate_steering_force()
	else:
		input_dir = Input.get_vector(left, right, up, down)
	
	if is_in_hitstun:
		input_dir *= 0
		if velocity.length() < launch_velocity*0.1:
			is_in_hitstun = false
	
	var direction = input_dir.normalized()
	
	
	if direction == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * FRICTION * delta
		else:
			velocity = Vector2.ZERO
	else:
		velocity += direction * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)

	if is_cpu:
		var diff = opponent.global_position - global_position
		set_target_rotation(atan2(diff.y, diff.x) + rotation_offset)
		rotation = lerp_angle(rotation, target_rotation, CPU_ROTATION_SPEED * delta)
	elif using_gamepad:
		if input_dir.length_squared() > 0.5:
			prev_joystick_position = input_dir
		rotation = rotation_offset + atan2(prev_joystick_position.y, prev_joystick_position.x)
	else:
		rotation = rotation_offset + atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x)

	if anim_player.current_animation == "melee":
		shield_node.visible = false
	elif anim_player.current_animation == "special":
		shield_node.visible = false
	elif anim_player.current_animation == "shield":
		pass
	elif input_dir != Vector2.ZERO:
		anim_player.play("move")
		shield_node.visible = false
	else:
		anim_player.play("idle")
		shield_node.visible = false
		
	var viewport_size = get_viewport_rect().size
	var width = viewport_size.x
	var height = viewport_size.y
	
	if global_position.x > width:
		global_position.x -= width * 2
		set_target_position(target_position - + Vector2(width * 2, 0))
	elif global_position.x < -width:
		global_position.x += width * 2
		set_target_position(target_position + Vector2(width * 2, 0))
	if global_position.y > height:
		global_position.y -= height * 2
		set_target_position(target_position - Vector2(0, height * 2))
	elif global_position.y < -height:
		global_position.y += height * 2
		set_target_position(target_position + Vector2(0, height * 2))

	if !anim_player.current_animation == "shield":
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())

func calculate_steering_force() -> Vector2:
	var desired_velocity = (target_position - global_position)
	var steering = desired_velocity - velocity
	return steering

func set_target_position(target: Vector2):
	target_position = target
	
func set_target_rotation(target: float):
	target_rotation = target

@rpc("call_local")
func play_melee_effects():
	anim_player.stop()
	anim_player.play("melee")
	print("createbarrier")
	create_barrier.rpc()
	
@rpc("call_local")
func play_special_effects():
	anim_player.stop()
	anim_player.play("special")
	
@rpc("call_local")
func play_shield_effects():
	anim_player.stop()
	anim_player.play("shield")
	shield_node.visible = true
	
@rpc("call_local")
func play_parry_effects():
	anim_player.stop()
	anim_player.play("parry")
	shield_node.visible = false
	parry_particles.restart()
	GameManager.play_sound("Parry")
	GameManager.hitlag(0.05, 1.0)
	var candle_id = get_available_candle()
	if candle_id >= 0:
		GameManager.candle_lit.emit(candle_id, id, true)
	parry_particles.emitting = true
	
func get_available_candle():
	var result = -1
	for i in range(GameManager.candles_belong_to.size()):
		#candle already belongs to this player
		if GameManager.candles_belong_to[i] == id:
			continue
		#light a neutral candle if you can
		elif GameManager.candles_belong_to[i] == 0:
			return i
		#only take a contested candle if there's nothing else
		elif GameManager.candles_belong_to[i] == -1:
			if result == -1:
				result = i
		#belongs to opponent is better than contested
		else:
			result = i
	return result
	
@rpc("call_local")
func play_passive_effects():
	anim_player.stop()
	anim_player.play("passive")
	passive_hit_particles.restart()
	GameManager.hitlag(0.05, 0.2)
	GameManager.play_sound("Hit")
	passive_hit_particles.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector2.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "melee":
		anim_player.play("idle")
	if anim_name == "special":
		anim_player.play("idle")
	if anim_name == "passive":
		anim_player.play("idle")
	if anim_name == "shield":
		shield_node.visible = false
		anim_player.play("idle")

func _on_passive_hitbox_body_entered(body):
	if not body is Player:
		return
	if body.id == id:
		return
	if body.anim_player.current_animation == "shield":
		print("player", id, " got parried")
		if GameManager.is_online and not is_multiplayer_authority():
			body.play_parry_effects.rpc()
		else:
			body.play_parry_effects()
	else:
		var effective_velocity = velocity.length()
		if effective_velocity < 100:
			effective_velocity = 0
		var force_imparted = PASSIVE_FORCE + (effective_velocity * PASSIVE_FORCE_TRANSFERRED)
		force_imparted = clamp(force_imparted, MIN_FORCE, MAX_FORCE)
		body.velocity += (body.position - position).normalized() * force_imparted
		body.launch_velocity = body.velocity.length()
		body.is_in_hitstun = true
		if GameManager.is_online and is_multiplayer_authority():
			play_passive_effects.rpc()
		else:
			play_passive_effects()
	
