extends Area2D

@onready var fora = $Preto
@onready var dentro = $Transparente

func _on_body_entered(body: Node2D) -> void:
	dentro.visible = true
	fora.visible = false


func _on_body_exited(body: Node2D) -> void:
	dentro.visible = false
	fora.visible = true
