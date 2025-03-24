extends Area2D

signal took_damage(amount: float, source: Node)

func take_damage(amount: float, source: Node) -> void:
	print("Punching Bag took %s damage from %s" % [amount, source.name])
	# Add visual feedback here if wanted

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_attacking"):
		take_damage(area.damage_amount, area.owner)
