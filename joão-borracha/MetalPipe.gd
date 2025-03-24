extends Area2D

@export var damage_multiplier: float = 1.0
@export var weight: float = 1.0  # Higher weight = slower swings
@export var base_damage: float = 10.0

var is_held: bool = false
var last_position: Vector2
var current_speed: float = 0.0

func _ready() -> void:
	# Set up collision detection
	area_entered.connect(_on_area_entered)
	last_position = global_position

func _process(delta: float) -> void:
	if is_held:
		# Calculate speed based on movement
		current_speed = (global_position - last_position).length() / delta
		last_position = global_position

func pick_up(hand: Node2D) -> void:
	is_held = true
	# Reparent to hand
	get_parent().remove_child(self)
	hand.add_child(self)
	# Position behind hand
	z_index = hand.z_index - 1
	position = Vector2.ZERO  # Center in hand

func release() -> void:
	is_held = false
	# Reset z-index
	z_index = 0

func _on_area_entered(area: Area2D) -> void:
	if is_held && area.has_method("take_damage"):
		# Calculate damage based on speed and weight
		var damage = (current_speed * damage_multiplier) / weight + base_damage
		area.take_damage(damage, self)
