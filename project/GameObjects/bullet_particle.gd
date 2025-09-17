extends CPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.bullet_particle_added.connect(_on_bullet_particle_added)
	
func _on_bullet_particle_added(payload=null):
	var dir = payload["facing"]
	transform = transform.looking_at(dir)
	one_shot = true
	emitting = true
