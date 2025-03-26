# BaseHand.gd
extends Node2D
class_name BaseHand

enum HandState { EMPTY, GUN, MELEE }
@export var current_state: HandState = HandState.EMPTY
@export var animation_player: AnimationPlayer  # Set in inspector for each hand

var nearby_weapons: Array = []

@onready var grab_area: Area2D = $GrabArea

func _ready() -> void:
	grab_area.body_entered.connect(_on_weapon_entered)
	grab_area.body_exited.connect(_on_weapon_exited)

func _on_weapon_entered(weapon: Node) -> void:
	if weapon.is_in_group("Weapon") && !weapon.is_held:
		weapon.highlight()
		if !nearby_weapons.has(weapon):
			nearby_weapons.append(weapon)

func _on_weapon_exited(weapon: Node) -> void:
	if nearby_weapons.has(weapon):
		weapon.unhighlight()
		nearby_weapons.erase(weapon)

func update_state(new_state: HandState) -> void:
	current_state = new_state
	var anim_name := "Empty"
	
	match new_state:
		HandState.GUN:
			anim_name = "HoldingGun"
		HandState.MELEE:
			anim_name = "HoldingMelee"
	
	animation_player.play(anim_name)

func try_grab_weapon() -> void:
	if nearby_weapons.size() > 0:
		var weapon = nearby_weapons[0]
		weapon.pick_up(self)
		update_state(weapon.weapon_type)
		nearby_weapons.clear()
