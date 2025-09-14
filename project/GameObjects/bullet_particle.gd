extends CPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(0.3).timeout.connect(queue_free)
