extends CharacterBody2D

var vida_atual = 10 
var vida_maxima = 10  
var dano = 1  # You need to define how much damage is applied
@onready var text = $Label  # Use @onready to ensure the node is available when ready

func _on_area_2d_body_entered(body: Node2D) -> void:
	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  
	text.text = str("-10hp")  # Update the label text to show current health
	if vida_atual <= 0:
		queue_free()
