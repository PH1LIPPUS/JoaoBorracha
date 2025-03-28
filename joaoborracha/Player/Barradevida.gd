extends CanvasLayer

@onready var barra_sprite = $BarraSprite  

var vida_atual = 10 
var vida_maxima = 10  

func _ready():
	update_barra()
	
func receber_dano(dano):
	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  

	if vida_atual <= 0:
		get_parent().die()  

	update_barra()
	
func update_barra():
	barra_sprite.frame = vida_atual
