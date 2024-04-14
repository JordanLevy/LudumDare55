extends CharacterBody2D

class_name Player

signal health_changed(health_value)

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var passive_hit_particles = $PassiveHitParticles

var id: int = 2
var health = 100
const ACCELERATION = 1800
const MAX_SPEED = 400
const FRICTION = 800

var using_gamepad: bool = false
var mouse_position: Vector2 = Vector2.ZERO
var prev_joystick_position: Vector2 = Vector2.ZERO
var mouse_offset_angle = -PI/2

var is_in_hitstun: bool = false;

const PASSIVE_FORCE = 450
const PASSIVE_FORCE_TRANSFERRED = 1.2

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	set_texture()
	if not is_multiplayer_authority(): return
	
func set_texture():
	if id == 1:
		sprite.texture = load("res://Player/WizardRed.png")
	elif id == 2:
		sprite.texture = load("res://Player/WizardBlue.png")

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if(event is InputEventJoypadButton):
		using_gamepad = true
	elif(event is InputEventJoypadMotion):
		using_gamepad = true
	elif(event is InputEventKey):
		using_gamepad = false
	elif(event is InputEventMouseButton):
		using_gamepad = false
	elif event is InputEventMouseMotion:
		using_gamepad = false
		mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("melee") and !is_attacking():
		play_melee_effects.rpc()
		#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
		
	if Input.is_action_just_pressed("special") and !is_attacking():
		play_special_effects.rpc()
		#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func is_attacking():
	return anim_player.current_animation == "melee" or anim_player.current_animation == "special"

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	#if GameManager.game_state != GameManager.GameState.PLAYING:
		#return

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = input_dir.normalized()
	
	if direction == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * FRICTION * delta
		else:
			velocity = Vector2.ZERO
	else:
		velocity += direction * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)

	
	if using_gamepad:
		if input_dir.length_squared() > 0.5:
			prev_joystick_position = input_dir
		rotation = atan2(prev_joystick_position.y, prev_joystick_position.x)
	else:
		rotation = mouse_offset_angle + atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x)

	if anim_player.current_animation == "melee":
		pass
	elif input_dir != Vector2.ZERO:
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

@rpc("call_local")
func play_melee_effects():
	anim_player.stop()
	anim_player.play("melee")
	print("melee")
	
@rpc("call_local")
func play_special_effects():
	anim_player.stop()
	anim_player.play("special")
	print("special")
	
@rpc("call_local")
func play_passive_effects():
	anim_player.stop()
	anim_player.play("passive")
	passive_hit_particles.restart()
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

func _on_passive_hitbox_body_entered(body):
	if not body is Player:
		return
	if body.id == id:
		return
	var force_imparted = (velocity.length() * PASSIVE_FORCE_TRANSFERRED)
	print(force_imparted)
	body.velocity += (body.position - position).normalized() * (PASSIVE_FORCE + force_imparted)
	if is_multiplayer_authority():
		play_passive_effects.rpc()
	
