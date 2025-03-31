extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var speed = 500
var lifetime = 4.0
var damage = 10

func _ready():
	global_position = pos
	global_rotation = rota
	
	# Setup bullet cleanup timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(Callable(self, "queue_free"))
	timer.start()
	
func _physics_process(delta):
	# Make sure direction is properly set from rotation
	velocity = Vector2(speed, 0).rotated(rota)
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		handle_collision(collision)

func handle_collision(collision):
	var collider = collision.get_collider()
	
	# Check if collider has health or is damageable
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	
	# Spawn impact effect if needed
	# spawn_impact_effect(collision.get_position())
	
	# Remove the bullet
	queue_free()

# Properly named collision function
func _on_area_entered(area):
	queue_free()

func _on_body_entered(body):
	queue_free()
