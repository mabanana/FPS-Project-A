extends Node
class_name Gun

@export var gun_resource: GunResource
var mag_curr: int
var id: int

func _ready():
	mag_curr = gun_resource.mag_size

func _init():
	#TODO create object id assign global method
	id = 123
