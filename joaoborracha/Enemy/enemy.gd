extends CharacterBody2D

# Enemy Properties
var speed = 100
var health = 10
var direction = 1  
var patrol_distance = 200
var start_position = Vector2.ZERO

# Shooting Properties
var bullet_scene = preload("res://Resources/Guns/Bullets/bullet.tscn")  # Replace with your bullet path
var can_shoot = true
var shoot_cooldown = 1.0  # Time between shots in seconds
var detection_range = 300  # How far the enemy can detect the player

# References
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var gun_position = $LeftHand/LEFTY  # Using the left hand as gun position based on your scene tree

func _ready():
	start_position = global_position
	
	# Setup shooting cooldown timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = shoot_cooldown
	timer.one_shot = false
	timer.timeout.connect(Callable(self, "reset_shoot_cooldown"))
	timer.start()
	
	# Setup detection area if it doesn't exist
	if !has_node("DetectionArea"):
		var area = Area2D.new()
		area.name = "DetectionArea"
		add_child(area)
		
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = detection_range
		collision.shape = shape
		area.add_child(collision)
		
		# Connect the detection signal
		area.body_entered.connect(Callable(self, "_on_detection_area_body_entered"))
		area.body_exited.connect(Callable(self, "_on_detection_area_body_exited"))
		
		detection_area = area

func _physics_process(delta):
	patrol(delta)
	
	# Update gun position to always point at player if player is detected
	var player = find_player_in_range()
	if player:
		look_at_player(player)
		if can_shoot:
			shoot_at_player(player)

func patrol(delta):
	# Move side to side within patrol_distance
	if global_position.x > start_position.x + patrol_distance:
		direction = -1
		flip_sprite(true)
	elif global_position.x < start_position.x - patrol_distance:
		direction = 1
		flip_sprite(false)
		
	velocity.x = direction * speed
	velocity.y = 0
	
	move_and_slide()

func flip_sprite(flip_h):
	if animated_sprite:
		animated_sprite.flip_h = flip_h

func find_player_in_range():
	# Find player in the scene
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		var player_node = player[0]
		var distance = global_position.distance_to(player_node.global_position)
		if distance <= detection_range:
			return player_node
	return null

func look_at_player(player):
	# Make the gun point at the player
	var gun = $LeftHand/LEFTY if has_node("LeftHand/LEFTY") else $RightHand/RIGHTY
	if gun:
		gun.look_at(player.global_position)

func shoot_at_player(player):
	# Create a bullet
	var bullet = bullet_scene.instantiate()
	
	# Get gun position
	var gun = $LeftHand/LEFTY if has_node("LeftHand/LEFTY") else $RightHand/RIGHTY
	var spawn_position = gun.global_position if gun else global_position
	
	# Calculate direction to player
	var direction = (player.global_position - spawn_position).normalized()
	var angle = direction.angle()
	
	# Set bullet properties from your bullet script
	bullet.pos = spawn_position
	bullet.rota = angle
	bullet.dir = direction.x
	
	# Add bullet to the scene
	get_tree().root.add_child(bullet)
	
	# Start cooldown
	can_shoot = false

func reset_shoot_cooldown():
	can_shoot = true

func take_damage(amount):
	health -= amount
	
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.5, 0.5)  
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1)  
	
	if health <= 0:
		die()

func die():
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		# Player detected, start shooting
		can_shoot = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		# Player left detection area, stop shooting
		can_shoot = false
