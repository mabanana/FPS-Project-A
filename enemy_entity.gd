extends CharacterBody3D
class_name EnemyEntity

@onready var damage_number: PackedScene = preload("res://damage_number.tscn")
const POSITION_FORESHORTEN = 1
var id: int

# TODO: add children to untracked entities
func take_damage(damage_floor, damage_ceiling, dealer, damage_position):
	var new_damage_number = damage_number.instantiate()
	new_damage_number.damage_number = randf_range(damage_floor, damage_ceiling)
	new_damage_number.damage_scale = float(new_damage_number.damage_number - damage_floor) / (damage_ceiling - damage_floor)
	var direction_to_dealer = position.direction_to(dealer.position)
	new_damage_number.position = (damage_position - position) + (direction_to_dealer * POSITION_FORESHORTEN)
	add_child(new_damage_number)
