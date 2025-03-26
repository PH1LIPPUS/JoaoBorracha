extends CharacterBody2D

# Variáveis de controle
@onready var barra_de_vida = $"Barra de vida"

# Movimento
@export var walk_speed: float = 150.0
@export var run_speed: float = 300.0
@export var slow_speed: float = 75.0
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0

# Pulo/gravidade
@export var gravity: float = 800.0
@export var max_fall_speed: float = 900.0
@export var jump_force: float = -300.0
@export var air_control_factor: float = 0.1

# Mãos
@export var hand_orbit_radius: float = 20.0
@export var hand_offset_multiplier: float = 0.2
@export var hand_move_speed: float = 10.0
@export var base_hand_angle_offset: float = 30.0
@export var precise_hand_transition_duration: float = 0.2

# Variáveis internas
var current_hand_angle_offset: float = 30.0
var precise_aim: bool = false
var precision_tween: Tween
var current_speed: float = 0.0
var vertical_velocity: float = 0.0
var is_jumping: bool = false

# Nodes
@onready var sprite: AnimatedSprite2D = $player
@onready var left_hand: Node2D = $LeftHand
@onready var right_hand: Node2D = $RightHand
@onready var hleft: AnimatedSprite2D = $LeftHand/LEFTY
@onready var hright: AnimatedSprite2D = $RightHand/RIGHTY

func _ready():
	hleft.play("idle")
	hright.play("idle")
	if !barra_de_vida:
		push_error("Barra de vida não encontrada!")

func _input(event):
	if event.is_action_pressed("ui_0"):
		test_take_damage()
	if event.is_action_pressed("precision_aim"):
		set_precision_aim(true)
	elif event.is_action_released("precision_aim"):
		set_precision_aim(false)

func _physics_process(delta):
	# Movimento
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	
	# Mãos e animação
	update_hand_positions(get_global_mouse_position())
	update_animation()
	move_and_slide()

func apply_gravity(delta):
	vertical_velocity += gravity * delta if not is_on_floor() else 0
	vertical_velocity = min(vertical_velocity, max_fall_speed)
	velocity.y = vertical_velocity

func handle_movement(delta):
	var direction = Input.get_axis("left", "right")
	var target_speed = direction * (
		run_speed if Input.is_action_pressed("run") else
		slow_speed if Input.is_action_pressed("slow_move") else
		walk_speed
	)
	var accel = acceleration if is_on_floor() else acceleration * air_control_factor
	velocity.x = lerp(velocity.x, target_speed, accel * delta) if direction else lerp(velocity.x, 0.0, deceleration * delta)

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		position.y -= 1.0  
		vertical_velocity = jump_force
		is_jumping = true

func update_hand_positions(mouse_pos):
	if not precise_aim:
		sprite.flip_h = mouse_pos.x < global_position.x
	
	var dir = (mouse_pos - global_position).normalized()
	var radius = hand_orbit_radius + (global_position.distance_to(mouse_pos) * hand_offset_multiplier)
	var angle = deg_to_rad(current_hand_angle_offset)
	
	for hand in [left_hand, right_hand]:
		var hand_angle = dir.angle() + (angle if hand == right_hand else -angle)
		hand.global_position = lerp(
			hand.global_position,
			global_position + Vector2(cos(hand_angle), sin(hand_angle)) * radius,
			hand_move_speed * get_process_delta_time()
		)
		hand.look_at(mouse_pos)

func update_animation():
	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0 else "fall")
	elif abs(velocity.x) > 10:
		sprite.play("run" if Input.is_action_pressed("run") else "walk")
	else:
		sprite.play("idle")

func set_precision_aim(enable):
	precise_aim = enable
	if precision_tween:
		precision_tween.kill()
	
	precision_tween = create_tween().set_trans(Tween.TRANS_SINE)
	precision_tween.tween_property(
		self, "current_hand_angle_offset", 
		0.0 if enable else base_hand_angle_offset, 
		precise_hand_transition_duration
	)
	hleft.play("aim" if enable else "idle")
	hright.play("aim" if enable else "idle")

# Sistema de vida
func receber_dano(dano):
	if barra_de_vida:
		barra_de_vida.receber_dano(dano)

func receber_cura(cura):
	if barra_de_vida:
		barra_de_vida.vida_atual = clamp(barra_de_vida.vida_atual + cura, 0, barra_de_vida.vida_maxima)
		barra_de_vida.update_barra()

func test_take_damage():
	receber_dano(1)
	print("Vida: ", barra_de_vida.vida_atual if barra_de_vida else "N/A")
