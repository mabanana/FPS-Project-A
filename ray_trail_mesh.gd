extends MeshInstance3D

var direction
var speed
var distance

func _physics_process(delta):
	position += direction * speed * delta
	distance -= speed * delta
	if distance <= 0:
		queue_free()
	
