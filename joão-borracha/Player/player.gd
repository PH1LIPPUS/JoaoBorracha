extends CharacterBody2D

@export var speed: float = 200.0
@export var run_speed: float = 400.0
@export var jump_force: float = 400.0
@export var gravity: float = 900.0
@export var max_health: int = 100
@export var max_stamina: int = 100
@export var stamina_cost: float = 10.0

var health: int = max_health
var stamina: int = max_stamina

@onready var hands: Marker2D = $Hands

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	var current_speed = speed

	if Input.is_action_pressed("sprint") and use_stamina(stamina_cost * delta):
		current_speed = run_speed

	velocity.x = direction * current_speed

	# Pulo
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	regenerate_stamina(delta)

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	var max_distance = 30.0  
	hands.position = direction * max_distance

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	print("Player morreu!")

func use_stamina(amount: int) -> bool:
	if stamina >= amount:
		stamina -= amount
		return true
	return false

func regenerate_stamina(delta: float) -> void:
	if stamina < max_stamina:
		stamina += 10 * delta
