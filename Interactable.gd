extends RigidBody3D
class_name Interactable

var resource_node: Node

func on_interact():
	queue_free()
	return get_resource_node()

func _ready():
	if not resource_node:
		queue_free()

func get_resource_node():
	return resource_node
