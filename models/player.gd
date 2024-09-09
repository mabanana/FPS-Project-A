class_name PlayerModel

var hp: int

var is_reloading: bool
var is_triggering: bool
var is_ads: bool

func _init(hp: int = 100) -> void:
	self.hp = hp
	is_reloading = false
	is_triggering = false
	is_ads = false
