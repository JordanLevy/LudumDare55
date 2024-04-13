extends CharacterBody2D

signal health_changed(health_value)

@onready var anim_player = $AnimationPlayer

var health = 100
const ACCELERATION = 900.0
const MAX_SPEED = 600.0
const GROUND_FRICTION = 0.99

var using_gamepad: bool = false
var mouse_position: Vector2
var prev_joystick_position: Vector2

var is_in_hitstun: bool = false;

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	velocity = Vector2.ZERO
	position = get_viewport_rect().size / 2.0
	if not is_multiplayer_authority(): return

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
		mouse_position = event.position
	
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

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = input_dir.normalized()
	velocity += direction * ACCELERATION * delta
	if !is_in_hitstun:
		velocity *= GROUND_FRICTION
	velocity = velocity.clamp(Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))

	
	if using_gamepad:
		if input_dir.length_squared() > 0.5:
			prev_joystick_position = input_dir
		rotation = atan2(prev_joystick_position.y, prev_joystick_position.x)
	else:
		rotation = atan2(mouse_position.y - position.y, mouse_position.x - position.x)

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
