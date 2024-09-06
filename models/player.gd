class_name PlayerModel

var hp: int
var reloading: bool

func _init(hp: int = 100) -> void:
	self.hp = hp
	reloading = false
