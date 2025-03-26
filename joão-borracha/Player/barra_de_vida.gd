extends CanvasLayer

@onready var barra_sprite = $BarraSprite
@export var vida_atual: int = 10
@export var vida_maxima: int = 10
var esta_bloqueando: bool = false

func _ready():
	update_barra()
	
func receber_dano(dano: int):
	if esta_bloqueando: 
		dano = dano / 2 

	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  

	if vida_atual <= 0:
		if get_parent().has_method("die"):
			get_parent().die()  

	update_barra()

func update_barra():
	if barra_sprite:
		barra_sprite.frame = vida_atual
	else:
		print("Erro: BarraSprite não encontrado!")
