extends CharacterBody2D

# Enemy Properties
var speed = 100
var health = 10
var direction = 1  # 1 = right, -1 = left
var patrol_distance = 200
var start_position = Vector2.ZERO
var is_shooting = false  # Variável para controlar quando o inimigo está atirando

# Shooting Properties
var bullet_scene = preload("res://Resources/Guns/Bullets/bulletsmg.tscn")  # Replace with your enemy bullet path
var can_shoot = true
var shoot_cooldown = 0.5 
var detection_range = 500 

# References
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var left_hand = $LeftHand
@onready var right_hand = $RightHand
@onready var gun = $LeftHand/LEFTY if has_node("LeftHand/LEFTY") else $RightHand/RIGHTY

func _ready():
	# Add to enemy group
	add_to_group("enemy")
	
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
	var player = find_player_in_range()
	
	if player:
		# Se o jogador for detectado, pare de andar e comece a atirar
		is_shooting = true
		aim_at_player(player)
		if can_shoot:
			shoot_at_player(player)
		velocity = Vector2.ZERO  # Pare o movimento enquanto atira
	else:
		# Se não há jogador detectado, continue patrulhando normalmente
		is_shooting = false
		patrol(delta)
	
	move_and_slide()

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

func flip_sprite(flip_h):
	if animated_sprite:
		animated_sprite.flip_h = flip_h

func find_player_in_range():
	# Find player in the scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player_node = players[0]
		var distance = global_position.distance_to(player_node.global_position)
		if distance <= detection_range:
			return player_node
	return null

func aim_at_player(player):
	# Somente rotaciona a arma, não o personagem inteiro
	if gun:
		var facing_left = animated_sprite.flip_h
		
		# Determina para qual lado o inimigo está olhando
		if player.global_position.x < global_position.x:
			# Jogador está à esquerda
			if !facing_left:
				flip_sprite(true)  # Vira o sprite para a esquerda
		else:
			# Jogador está à direita
			if facing_left:
				flip_sprite(false)  # Vira o sprite para a direita
		
		# Faz apenas a arma apontar para o jogador, sem modificar a orientação do personagem
		var target_pos = player.global_position
		
		# Ajusta a rotação da arma sem girar o personagem
		var angle_to_target = (target_pos - gun.global_position).angle()
		
		# Se o inimigo estiver olhando para a esquerda, inverte o ângulo da arma 
		if facing_left:
			gun.rotation = angle_to_target + PI  # Adiciona 180 graus quando virado para a esquerda
		else:
			gun.rotation = angle_to_target

func shoot_at_player(player):
	# Create a bullet
	var bullet = bullet_scene.instantiate()
	
	# Get gun position
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
	
	# Flash or show hit animation
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.5, 0.5)  # Tint red
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1)  # Reset tint
	
	if health <= 0:
		die()

func die():
	# Remove the enemy
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		# Player detected, start shooting
		can_shoot = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		# Player left detection area, stop shooting
		can_shoot = false
