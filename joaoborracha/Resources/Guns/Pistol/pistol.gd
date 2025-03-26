extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2
@export var damage: int = 1
@export var bullet_speed: float = 500.0

var can_shoot = true
var is_held = false
var holder: Node2D = null

func pickup(new_holder):
	holder = new_holder
	is_held = true
	get_parent().remove_child(self)
	holder.add_child(self)
	position = Vector2.ZERO

func drop():
	is_held = false
	if holder:
		holder.remove_child(self)
		get_tree().current_scene.add_child(self)
		global_position = holder.global_position
	holder = null

func shoot():
	if can_shoot and is_held and bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = $Muzzle.global_position
		bullet.rotation = global_rotation
		bullet.set_velocity(Vector2(bullet_speed, 0).rotated(global_rotation))
		bullet.damage = damage
		
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func _process(delta):
	if is_held and holder:
		look_at(get_global_mouse_position())
