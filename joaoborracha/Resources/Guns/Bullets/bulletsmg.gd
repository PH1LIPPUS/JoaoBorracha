extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var speed = 400
var lifetime = 3.0
var damage = 1
var shooter_type = "enemy"  # Identifier to know this bullet came from enemy

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
	
	
	# Setup collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8, 4)
	collision.shape = shape
	add_child(collision)
	
	# Setup area for detecting player
	var area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = RectangleShape2D.new()
	area_shape.size = Vector2(10, 6)  # Slightly larger than collision
	area_collision.shape = area_shape
	area.add_child(area_collision)
	add_child(area)
	
	# Connect area signals
	area.body_entered.connect(Callable(self, "_on_area_body_entered"))

func _physics_process(delta):
	# Make sure direction is properly set from rotation
	velocity = Vector2(speed, 0).rotated(rota)
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		handle_collision(collision)

func handle_collision(collision):
	var collider = collision.get_collider()
	
	# Check if collider is the player
	if collider.is_in_group("player"):
		# Deal damage to player
		if collider.has_method("receber_dano"):
			collider.receber_dano(damage)
	
	# Remove the bullet
	queue_free()

func _on_area_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("player"):
		# Deal damage to player
		if body.has_method("receber_dano"):
			body.receber_dano(damage)
		queue_free()
	elif not body.is_in_group("enemy"):  # Don't collide with other enemies
		queue_free()




func _on_bullet_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
