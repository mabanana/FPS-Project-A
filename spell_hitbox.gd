class_name SpellHitbox
extends Area3D
var linear_velocity: Vector3
var caster: int
var lifetime: float = 2
var rid: int

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_collided)
	transform = transform.looking_at(linear_velocity)
	rotation.x += 90
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime -= delta
	if lifetime < 0:
		print("Hitbox timed out")
		lifetime_end()

func _physics_process(delta):
	position += linear_velocity * delta

func on_collided(body):
	if body.has_method("take_damage"):
		body.core_changed.emit(CoreServices.Context.hitbox_collided, 
		{
			"target_rid": body.rid,
			"dealer_rid": caster,
			"target_position": body.global_position + body.eye_pos,
		})
		prints("Hitbox collision detected with", body)
		lifetime_end()
	

func lifetime_end():
	queue_free()
