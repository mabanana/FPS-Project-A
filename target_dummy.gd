extends CharacterBody3D
class_name TargetDummy
@onready var damage_number: PackedScene = preload("res://DamageNumber.tscn")

func take_damage(damage, dealer):
	var new_damage_number = damage_number.instantiate()
	new_damage_number.damage_number = damage
	var direction_to_dealer = position.direction_to(dealer.position)
	new_damage_number.position += direction_to_dealer*1.5
	add_child(new_damage_number)
