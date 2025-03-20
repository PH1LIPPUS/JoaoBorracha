extends CharacterBody2D

@export var speed: float = 200.0
@export var run_speed: float = 400.0
@export var jump_force: float = 400.0
@export var gravity: float = 900.0
@export var max_health: int = 100

var health: int = max_health

@onready var hands: Marker2D = $Hands
@onready var sprite: Sprite2D = $Sprite2D  

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	var current_speed = speed

	if Input.is_action_pressed("sprint"):
		current_speed = run_speed

	velocity.x = direction * current_speed

	# Pulo
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	hands.rotation = direction.angle()

	var max_distance = 30.0  
	hands.position = direction * max_distance

	if mouse_position.x > global_position.x:

		sprite.flip_h = false  
		hands.flip_h = false 
	else:
		sprite.flip_h = true 
		hands.flip_h = false 

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	print("Player morreu!")
