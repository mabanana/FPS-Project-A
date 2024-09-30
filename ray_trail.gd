extends GPUParticles3D

func _ready():
	finished.connect(_on_emission_finished)

func _on_emission_finished():
	queue_free()

func _process(delta):
	prints("currently traveling in direction:", process_material.direction)
