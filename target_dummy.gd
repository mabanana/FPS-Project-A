extends CharacterBody3D
class_name TargetDummy
@onready var damage_number: PackedScene = preload("res://DamageNumber.tscn")
@onready var bullet_hole: PackedScene = preload("res://bullet_hole.tscn")
const POSITION_FORESHORTEN = 1

func take_damage(damage, dealer, damage_position):
	var new_damage_number = damage_number.instantiate()
	new_damage_number.damage_number = damage
	var direction_to_dealer = position.direction_to(dealer.position)
	new_damage_number.position = (damage_position - position) + (direction_to_dealer  * POSITION_FORESHORTEN)
	var new_bullet_hole = bullet_hole.instantiate()
	new_bullet_hole.position = (damage_position - position)
	add_child(new_bullet_hole)
	add_child(new_damage_number)
