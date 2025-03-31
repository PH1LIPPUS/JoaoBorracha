# ----- WEAPON CODE -----
extends RigidBody2D

var being_held = false
var holder: Node2D = null
var flip_offset: Vector2 = Vector2(0, 32)  # Offset when flipped left
var normal_offset: Vector2 = Vector2(0, 0)  # Offset when not flipped (right)
var original_collision_layer = 0
var original_collision_mask = 0

# Gun properties
var bullet_path = preload("res://Resources/Guns/Bullets/bullet.tscn")
var fire_rate = 0.2  # Time between shots in seconds
var can_shoot = true
var muzzle_velocity = 500  # Bullet speed

func _ready():
	# Store original collision settings
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	
	# Add to "weapons" group for easier reference
	add_to_group("weapons")
	
	# Setup firing cooldown timer
	var timer = Timer.new()
	timer.name = "ShootCooldown"
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = fire_rate
	timer.timeout.connect(Callable(self, "_on_shoot_cooldown_timeout"))

func _on_picked_up():
	being_held = true
	freeze = true
	visible = true
	
	# Disable collisions while being held
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

# Update orientation based on player facing direction
func update_flip(is_flipped: bool):
	if is_flipped:
		position = flip_offset
		scale.y = -1
	else:
		position = normal_offset
		scale.y = 1

func shoot():
	if !can_shoot:
		return
		
	# Create a new bullet instance
	var bullet = bullet_path.instantiate()
	
	# Get the muzzle/barrel position
	var muzzle_pos = $Node2D.global_position
	
	# Set bullet properties
	bullet.pos = muzzle_pos
	bullet.rota = global_rotation
	bullet.dir = global_rotation
	bullet.speed = muzzle_velocity
	
	# Add bullet to the scene (root level for independence from weapon)
	get_tree().current_scene.add_child(bullet)
	
	# Handle recoil/animation here if needed
	# apply_recoil()
	# play_shoot_animation()
	# spawn_muzzle_flash()
	
	# Start cooldown
	can_shoot = false
	$ShootCooldown.start()

func _on_shoot_cooldown_timeout():
	can_shoot = true

# Release the weapon when dropped
func drop():
	being_held = false
	freeze = false
	
	# Restore original collision settings
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
	# Add impulse when dropping
	apply_impulse(Vector2(0, -100), Vector2.ZERO)
