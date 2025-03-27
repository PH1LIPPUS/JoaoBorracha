extends CharacterBody2D

# Movement settings
@export var walk_speed: float = 150.0
@export var run_speed: float = 300.0
@export var slow_speed: float = 75.0
@export var acceleration: float = 15.0
@export var deceleration: float = 20.0

# Jump/gravity settings
@export var gravity: float = 800.0
@export var max_fall_speed: float = 900.0
@export var jump_force: float = -300.0
@export var air_control_factor: float = 0.5
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# Hands settings
@export var hand_orbit_radius: float = 20.0
@export var hand_offset_multiplier: float = 0.2
@export var hand_move_smoothness: float = 10.0
@export var base_hand_angle_offset: float = 30.0
@export var precise_hand_transition_duration: float = 0.2
@export var max_hand_distance: float = 150.0

# Nodes
@onready var sprite: AnimatedSprite2D = $player
@onready var left_hand: Node2D = $LeftHand
@onready var right_hand: Node2D = $RightHand
@onready var hleft: AnimatedSprite2D = $LeftHand/LEFTY
@onready var hright: AnimatedSprite2D = $RightHand/RIGHTY
@onready var barra_de_vida: Node = $"Barra de vida"

# Internal variables
var current_hand_angle_offset: float = base_hand_angle_offset
var precise_aim: bool = false
var precision_tween: Tween
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var facing_direction: int = 1  

func _ready():
	if $LeftHand/PickupArea:
		$LeftHand/PickupArea.connect("weapon_in_area_changed", Callable(self, "_update_weapon_in_area"))
	
	if $RightHand/PickupArea:
		$RightHand/PickupArea.connect("weapon_in_area_changed", Callable(self, "_update_weapon_in_area"))
		
	if hleft and hright:
		hleft.play("idle")
		hright.play("idle")
	else:
		push_error("Hand sprites not found!")
	
	if !barra_de_vida:
		push_error("Health bar not found!")

var weapon_in_area := false

func _update_weapon_in_area(is_weapon_in_area: bool):
	weapon_in_area = is_weapon_in_area 

func _input(event):
	if event.is_action_pressed("ui_0"):
		test_take_damage()
	if event.is_action_pressed("pickup") and weapon_in_area:
		pickup_weapon()  
	if event.is_action_pressed("precision_aim"):
		set_precision_aim(true)
	elif event.is_action_released("precision_aim"):
		set_precision_aim(false)

func _physics_process(delta):
	# Update timers
	update_timers(delta)
	
	# Movement
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	
	# Hands and animation
	update_hand_positions(get_global_mouse_position())
	update_animation()
	
	# Store previous frame's on_floor state
	was_on_floor = is_on_floor()
	
	# Move the character
	move_and_slide()

func update_timers(delta):
	# Coyote time timer
	if was_on_floor and not is_on_floor():
		coyote_timer = coyote_time
	elif is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	
	# Jump buffer timer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)

func handle_jump():
	# Check if we can jump (using coyote time)
	var can_jump = is_on_floor() or coyote_timer > 0
	
	# Jump if we have a buffered jump input and can jump
	if jump_buffer_timer > 0 and can_jump:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

func handle_movement(delta):
	var direction = Input.get_axis("left", "right")
	
	# Update facing direction
	if direction != 0:
		facing_direction = sign(direction)
	
	# Determine target speed
	var target_speed = 0.0
	if direction != 0:
		target_speed = direction * (
			run_speed if Input.is_action_pressed("run") else
			slow_speed if Input.is_action_pressed("slow_move") else
			walk_speed
		)
	
	# Apply acceleration/deceleration
	var current_accel = acceleration if direction != 0 else deceleration
	var control_factor = 1.0 if is_on_floor() else air_control_factor
	
	velocity.x = lerp(
		velocity.x, 
		target_speed, 
		current_accel * control_factor * delta
	)

func update_hand_positions(mouse_pos: Vector2):
	if not hleft or not hright:
		return
	
	# Calculate direction to mouse with distance limit
	var mouse_dir = (mouse_pos - global_position)
	var distance = mouse_dir.length()
	if distance > max_hand_distance:
		mouse_dir = mouse_dir.normalized() * max_hand_distance
	
	mouse_dir = mouse_dir.normalized()
	
	# Update sprite flip based on mouse position
	sprite.flip_h = mouse_pos.x < global_position.x
	
	# Calculate hand positions
	var angle_offset = deg_to_rad(current_hand_angle_offset)
	var radius = hand_orbit_radius + (distance * hand_offset_multiplier)
	
	# Calculate hand angles
	var right_angle = mouse_dir.angle() + angle_offset
	var left_angle = mouse_dir.angle() - angle_offset
	
	# Smoothly move hands to their positions
	var delta = get_process_delta_time()
	var smooth_factor = hand_move_smoothness * delta
	
	right_hand.global_position = lerp(
		right_hand.global_position,
		global_position + Vector2(cos(right_angle), sin(right_angle)) * radius,
		smooth_factor
	)
	
	left_hand.global_position = lerp(
		left_hand.global_position,
		global_position + Vector2(cos(left_angle), sin(left_angle)) * radius,
		smooth_factor
	)
	
	# Rotate hands to look at mouse
	right_hand.look_at(mouse_pos)
	left_hand.look_at(mouse_pos)
	
	# Flip hand sprites if needed
	if sprite.flip_h:
		hright.flip_v = true
		hleft.flip_v = true
	else:
		hright.flip_v = false
		hleft.flip_v = false

func update_animation():
	if not sprite:
		return
	
	if abs(velocity.x) > 10 and is_on_floor():
		# Andando
		sprite.play("walk")
		sprite.flip_h = velocity.x < 0
	else:
		# Parado ou no ar
		sprite.play("idle")

func set_precision_aim(enable: bool):
	if not hleft or not hright:
		return
	
	precise_aim = enable
	
	if precision_tween:
		precision_tween.kill()
	
	precision_tween = create_tween().set_trans(Tween.TRANS_SINE)
	precision_tween.tween_property(
		self, 
		"current_hand_angle_offset", 
		0.0 if enable else base_hand_angle_offset, 
		precise_hand_transition_duration
	)
	
	hleft.play("aim" if enable else "idle")
	hright.play("aim" if enable else "idle")

# Health system
func receber_dano(dano: int):
	if barra_de_vida:
		barra_de_vida.receber_dano(dano)

func receber_cura(cura: int):
	if barra_de_vida:
		barra_de_vida.vida_atual = clamp(
			barra_de_vida.vida_atual + cura, 
			0, 
			barra_de_vida.vida_maxima
		)
		barra_de_vida.update_barra()

func test_take_damage():
	receber_dano(1)
	print("Vida: ", barra_de_vida.vida_atual if barra_de_vida else "N/A")

func pickup_weapon():
	var pistol_scene = load("res://Resources/Guns/Pistol/pistol.tscn")
	
	var pistol_instance = pistol_scene.instantiate()
	
	if pistol_instance.has_method("_on_picked_up"):
		pistol_instance._on_picked_up()
	
