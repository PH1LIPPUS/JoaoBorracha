extends Area2D

signal weapon_in_area_changed(is_weapon_in_area)  

var weapon_in_area := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("weapon"):
		weapon_in_area = true
		emit_signal("weapon_in_area_changed", true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("weapon"):
		weapon_in_area = false
		emit_signal("weapon_in_area_changed", false)
