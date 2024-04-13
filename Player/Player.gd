extends CharacterBody2D

signal health_changed(health_value)

@onready var anim_player = $AnimationPlayer

var health = 3
const SPEED = 100.0

var mouse_position: Vector2

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		mouse_position = event.position
	
	if Input.is_action_just_pressed("melee") \
			and anim_player.current_animation != "melee":
		play_melee_effects.rpc()
		#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = input_dir.normalized()
	velocity = direction * SPEED
	rotation = atan2(mouse_position.y - position.y, mouse_position.x - position.x)

	if anim_player.current_animation == "melee":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

@rpc("call_local")
func play_melee_effects():
	anim_player.stop()
	anim_player.play("melee")
	print("melee")

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
