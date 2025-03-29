extends RigidBody2D

var being_held = false
var holder: Node2D = null
var flip_offset: Vector2 = Vector2(0, 32)  # Offset when flipped left
var normal_offset: Vector2 = Vector2(0, 0)  # Offset when not flipped (right)
var original_collision_layer = 0
var original_collision_mask = 0

func _ready():
	# Store original collision settings
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	
	# Add to "weapons" group for easier reference
	add_to_group("weapons")

func _on_picked_up():
	being_held = true
	freeze = true
	visible = true  # Garantir que está visível na mão
	
	# Desativar colisões enquanto estiver sendo segurada
	set_collision_layer_value(1, false)  # Camada do mundo
	set_collision_mask_value(1, false)   # Máscara do mundo

# Update flip based on mouse position relative to player
func update_flip(is_flipped: bool):
	if is_flipped:
		position = flip_offset
		scale.y = -1
	else:
		position = normal_offset
		scale.y = 1

var bullet_path=preload("res://Resources/Guns/Bullets/bullet.tscn")

func shoot():
	print("aa")
	
