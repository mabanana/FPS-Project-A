extends CharacterBody3D
class_name TargetDummy
@onready var damage_number: PackedScene = preload("res://DamageNumber.tscn")

func take_damage(damage):
	var new_damage_number = damage_number.instantiate()
	new_damage_number.damage_number = damage
	new_damage_number.position = Vector3.UP*1.5
	add_child(new_damage_number)
