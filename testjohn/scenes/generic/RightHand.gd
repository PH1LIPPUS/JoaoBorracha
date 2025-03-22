extends Node2D

enum HandState { EMPTY, GUN, MELEE }
@export var current_state: HandState = HandState.EMPTY
var nearby_weapons: Array = []

@onready var grab_area: Area2D = $GrabArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	grab_area.body_entered.connect(_on_weapon_entered)
	grab_area.body_exited.connect(_on_weapon_exited)

func _on_weapon_entered(weapon: Node) -> void:
	if weapon.is_in_group("Weapon"):
		weapon.highlight()
		nearby_weapons.append(weapon)

func _on_weapon_exited(weapon: Node) -> void:
	if weapon in nearby_weapons:
		weapon.unhighlight()
		nearby_weapons.erase(weapon)

func update_state(new_state: HandState) -> void:
	current_state = new_state
	match current_state:
		HandState.EMPTY: animation_player.play("Empty")
		HandState.GUN: animation_player.play("HoldingGun")
		HandState.MELEE: animation_player.play("HoldingMelee")
