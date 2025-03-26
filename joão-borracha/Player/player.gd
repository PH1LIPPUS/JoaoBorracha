extends CharacterBody2D

@onready var barra_de_vida = $"Barra de vida"

# Movement variables - MODIFIED
@export var walk_speed: float = 150.0
@export var run_speed: float = 300.0
@export var slow_speed: float = 75.0
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0

# Gravity and jump variables
@export var gravity: float = 800.0
@export var max_fall_speed: float = 900.0
@export var jump_force: float = -300.0  # Negative for upward jump
@export var air_control_factor: float = 0.1

# Bounce variables
@export var bounce_height: float = 5.0
@export var bounce_speed: float = 15.0

# Rotation variables
@export var max_rotation: float = 10.0  # Degrees
@export var rotation_speed: float = 5.0

# Overshoot variables
@export var overshoot_amount: float = 10.0
@export var overshoot_duration: float = 0.2
@export var overshoot_speed: float = 5.0

# Landing bounce variables
@export var landing_bounce_distance: float = 10
@export var landing_bounce_duration: float = 0.5

#hand shit
@export var hand_orbit_radius: float = 20.0
@export var hand_offset_multiplier: float = 0.2  # Adjusts distance based on mouse distance
@export var hand_move_speed: float = 10.0
@export var base_hand_angle_offset: float = 30.0
@export var precise_hand_transition_duration: float = 0.2

# Internal variables
var current_hand_angle_offset: float = 30.0
var precise_aim: bool = false
var precision_tween: Tween
var is_bouncing: bool = false
var is_moving: bool = false
var bounce_offset: float = 0.0
var current_speed: float = 0.0
var target_speed: float = 0.0
var vertical_velocity: float = 0.0
var is_jumping: bool = false
var was_on_floor: bool = true
var sprite_offset: Vector2 = Vector2.ZERO  # For non-conflicting sprite adjustments
var near_weapons: Array = []
@onready var sprite: Sprite2D = $Sprite2D
@onready var tween: Tween = create_tween()
@onready var left_hand: Node2D = $LeftHand
@onready var right_hand: Node2D = $RightHand

func _ready() -> void:
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab_left"):
		try_grab_weapon($LeftHand)
	elif event.is_action_pressed("grab_right"):
		try_grab_weapon($RightHand)
	if event.is_action_pressed("precision_aim"):
		set_precision_aim(true)
	elif event.is_action_released("precision_aim"):
		set_precision_aim(false)

func _process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_bounce_effect(delta)
	handle_rotation(delta)
	handle_overshoot()
	handle_landing_bounce()
	
	sprite.position = sprite_offset
	was_on_floor = is_on_floor()
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	update_hand_positions(mouse_pos)
	# Flip player sprite based on mouse position
	if precise_aim:
		return
	else:
		$RightHand/RIGHTY.flip_v = mouse_pos.x < global_position.x
		$LeftHand/LEFTY.flip_v = mouse_pos.x < global_position.x
		$Sprite2D.flip_h = mouse_pos.x < global_position.x

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		vertical_velocity += gravity * delta
		vertical_velocity = min(vertical_velocity, max_fall_speed)
	else:
		vertical_velocity = 0.0
		is_jumping = false  # Reset jump state when grounded

	velocity.y = vertical_velocity

func handle_movement(delta: float) -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("walk_left"):
		direction = -1.0
	elif Input.is_action_pressed("walk_right"):
		direction = 1.0
	
	# Determine target speed based on movement state
	var target_speed: float
	if Input.is_action_pressed("slow_move"):  # When Ctrl is pressed
		target_speed = direction * slow_speed
	elif Input.is_action_pressed("run"):  # When Shift is pressed
		target_speed = direction * run_speed
	else:
		target_speed = direction * walk_speed  # Normal walking speed

	# Air control adjustment
	var current_acceleration = acceleration if is_on_floor() else acceleration * air_control_factor

	if direction != 0:
		current_speed = lerp(current_speed, target_speed, current_acceleration * delta)
	else:
		current_speed = lerp(current_speed, 0.0, deceleration * delta)

	velocity.x = current_speed
	is_moving = abs(current_speed) > 10.0
	move_and_slide()

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Forcefully nudge the player upward to break floor collision
		global_position.y -= 1.0  # Tiny upward offset
		force_update_transform()  # Immediately apply position change
		
		# Apply jump velocity
		vertical_velocity = jump_force
		is_jumping = true

func handle_bounce_effect(delta: float) -> void:
	if is_moving and not is_jumping and is_on_floor():
		# Ground bounce animation
		bounce_offset += bounce_speed * delta
		sprite_offset.y = sin(bounce_offset) * bounce_height
	else:
		# Smoothly reset vertical offset
		sprite_offset.y = lerp(sprite_offset.y, 0.0, rotation_speed * delta)

func handle_rotation(delta: float) -> void:
	if is_moving and not is_jumping and is_on_floor():
		# Ground rotation
		var rotation_amount = sin(bounce_offset) * deg_to_rad(max_rotation)
		sprite.rotation = lerp(sprite.rotation, rotation_amount, rotation_speed * delta)
	else:
		# Reset rotation
		sprite.rotation = lerp(sprite.rotation, 0.0, rotation_speed * delta)

func handle_overshoot() -> void:
	if not is_moving:
		if tween.is_running():
			tween.stop()
		
		if abs(sprite_offset.x) > 0.1:
			tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "sprite_offset:x", 0.0, overshoot_duration)
	else:
		# Use delta from _process via get_process_delta_time()
		sprite_offset.x = lerp(sprite_offset.x, velocity.x * 0.05, overshoot_speed * get_process_delta_time())
		
func handle_landing_bounce():
	if just_landed() and not is_bouncing:
		is_bouncing = true
		
		# Create a new tween
		var land_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		# First: Move downward
		land_tween.tween_property(sprite, "position:y", landing_bounce_distance, landing_bounce_duration * 0.3)
		
		# Then: Return to original position
		land_tween.tween_property(sprite, "position:y", 0.0, landing_bounce_duration * 0.7)
		
		# Reset bounce state when done
		land_tween.finished.connect(func(): is_bouncing = false)
	
func just_landed() -> bool:
	# True ONLY when transitioning from air -> ground
	return is_on_floor() and not was_on_floor

func update_hand_positions(mouse_pos: Vector2) -> void:
	var direction_to_mouse: Vector2 = (mouse_pos - global_position).normalized()
	var mouse_distance: float = global_position.distance_to(mouse_pos)
	var dynamic_radius: float = hand_orbit_radius + (mouse_distance * hand_offset_multiplier)
	
	# Calculate angles with current offset
	var angle_offset = deg_to_rad(current_hand_angle_offset)
	var left_angle: float = direction_to_mouse.angle() - angle_offset
	var right_angle: float = direction_to_mouse.angle() + angle_offset
	
	# Smooth hand movement
	left_hand.global_position = lerp(
		left_hand.global_position,
		global_position + Vector2(cos(left_angle), sin(left_angle)) * dynamic_radius,
		hand_move_speed * get_process_delta_time()
	)
	
	right_hand.global_position = lerp(
		right_hand.global_position,
		global_position + Vector2(cos(right_angle), sin(right_angle)) * dynamic_radius,
		hand_move_speed * get_process_delta_time()
	)
	
	# Rotate hands
	left_hand.look_at(mouse_pos)
	right_hand.look_at(mouse_pos)
	
func _on_weapon_entered(weapon: Node2D) -> void:
	if weapon.is_in_group("Weapon"):
		weapon.highlight()  # Call a method on the weapon to enable glow
		near_weapons.append(weapon)

func _on_weapon_exited(weapon: Node2D) -> void:
	if weapon in near_weapons:
		weapon.unhighlight()
		near_weapons.erase(weapon)

func try_grab_weapon(hand: Node2D) -> void:
	var nearest_weapon: Node2D = null
	var shortest_distance: float = INF
	
	for weapon in hand.nearby_weapons:
		var distance = hand.global_position.distance_to(weapon.global_position)
		if distance < shortest_distance:
			nearest_weapon = weapon
			shortest_distance = distance
	
	if nearest_weapon:
		nearest_weapon.pickup(hand)  # Call weapon's pickup method
		hand.update_state(hand.HandState.GUN)  # Temporary - replace with weapon type
		$GunGrab.play()  # Grab sound

func set_precision_aim(enable: bool) -> void:
	precise_aim = enable
	var target_offset = 0.0 if enable else base_hand_angle_offset
	
	if precision_tween:
		precision_tween.kill()
	
	precision_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	precision_tween.tween_property(self, "current_hand_angle_offset", target_offset, precise_hand_transition_duration)

func receber_dano(dano: int) -> void:
	if barra_de_vida:
		barra_de_vida.receber_dano(dano)
	else:
		print("Aviso: Barra de vida não encontrada!")

func curar(cura: int) -> void:
	if barra_de_vida:
		barra_de_vida.vida_atual += cura
		barra_de_vida.vida_atual = clamp(barra_de_vida.vida_atual, 0, barra_de_vida.vida_maxima)
		barra_de_vida.update_barra()
