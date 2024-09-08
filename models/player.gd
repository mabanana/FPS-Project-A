class_name PlayerModel

var hp: int

var reloading: bool
var trigger: bool
var ads: bool

func _init(hp: int = 100) -> void:
	self.hp = hp
	reloading = false
	trigger = false
	ads = false
