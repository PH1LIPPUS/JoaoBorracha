extends CharacterBody2D


@onready var text =  $BagLabel

func _on_area_2d_body_entered(body: Node2D) -> void:
	text.text = "-10 hp"
	await get_tree().create_timer(0.2).timeout 
	text.text = ""
