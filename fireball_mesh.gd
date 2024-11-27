class_name Hitbox
extends Area3D
var linear_velocity: Vector3
var caster: int
var lifetime: float = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_collided)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime -= delta
	if lifetime < 0:
		lifetime_end()

func _physics_process(delta):
	position += linear_velocity * delta

func on_collided(body):
	prints("fireball collision detected with", body)

func lifetime_end():
	queue_free()
