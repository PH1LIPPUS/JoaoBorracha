extends CharacterBody2D

enum Estado {ANDANDO, PARADO}
var estado_atual: Estado = Estado.ANDANDO

@export var velocidade: float = 50.0
@export var distancia_andar: float = 100.0
@onready var anim = $Sganim
var direcao: int = 1  # 1 para direita, -1 para esquerda
var posicao_inicial: Vector2
var jogador_detectado: bool = false
var jogador_ref: Node2D = null

func _ready():
	posicao_inicial = global_position

func _physics_process(delta):
	match estado_atual:
		Estado.ANDANDO:
			anim.play("walk")
			andar_padrao(delta)
		Estado.PARADO:
			anim.play("idle")
			virar_para_jogador()

func andar_padrao(delta):
	if jogador_detectado:
		estado_atual = Estado.PARADO
		return
	
	# Movimentação padrão
	velocity.x = velocidade * direcao
	move_and_slide()
	
	# Verifica se chegou no limite do caminho
	if abs(global_position.x - posicao_inicial.x) >= distancia_andar:
		direcao *= -1
		scale.x *= -1  # Inverte o sprite

func virar_para_jogador():
	if not jogador_detectado:
		estado_atual = Estado.ANDANDO
		return
	
	if is_instance_valid(jogador_ref):
		# Vira para o jogador
		if jogador_ref.global_position.x > global_position.x:
			scale.x = abs(scale.x)  # Direita
		else:
			scale.x = -abs(scale.x)  # Esquerda

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("aaa")
		jogador_detectado = true
		jogador_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		jogador_detectado = false
		jogador_ref = null
