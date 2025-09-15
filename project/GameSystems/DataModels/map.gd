class_name MapModel

var entities: Dictionary[int, EntityModel]

func _init() -> void:
	entities = {}
	# { rid : EntityModel }
