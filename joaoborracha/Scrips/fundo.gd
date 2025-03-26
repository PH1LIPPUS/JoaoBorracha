extends Node2D

# Adjust these values to control how much each layer moves
@export var layer1_sensitivity: Vector2 = Vector2(0.1, 0.1)  # Front layer (moves most)
@export var layer2_sensitivity: Vector2 = Vector2(0.05, 0.05) # Middle layer
@export var layer3_sensitivity: Vector2 = Vector2(0.02, 0.02) # Back layer (moves least)

# Store original positions
var original_positions := []

func _ready():
# Store original positions of all layers
	for child in get_children():
		if child is TextureRect:
			original_positions.append(child.position)

# Make sure mouse is visible and can exit the window
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN if OS.has_feature("web") else Input.MOUSE_MODE_CONFINED)

func _process(_delta):
	var viewport_center = get_viewport_rect().size / 2
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_offset = mouse_pos - viewport_center

# Apply parallax effect to each layer
	for i in range(min(get_child_count(), original_positions.size())):
		var child = get_child(i)
		if child is TextureRect:
			var sensitivity = layer1_sensitivity
			if i == 1:
				sensitivity = layer2_sensitivity
			elif i == 2:
				sensitivity = layer3_sensitivity
			
			child.position = original_positions[i] + mouse_offset * sensitivity
