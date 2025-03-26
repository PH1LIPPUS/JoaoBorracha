extends Area2D

var speed: float = 500.0
var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var lifetime: float = 2.0  # Tempo até a bala desaparecer

func set_velocity(direction: Vector2):
	velocity = direction

func _ready():
	# Destrói a bala após um tempo se não acertar nada
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.has_method("receber_dano"):
		body.receber_dano(damage)
	queue_free()  
