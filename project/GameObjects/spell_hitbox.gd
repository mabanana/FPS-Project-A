class_name SpellHitbox
extends Area3D
var linear_velocity: Vector3
var caster: int
var lifetime: float = 2
var rid: int
var entity_model: EntityModel
var lifetime_ended := false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_collided)
	look_at(global_position + linear_velocity)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime -= delta
	if lifetime < 0:
		#print("Hitbox timed out")
		lifetime_end()

func _physics_process(delta):
	position += linear_velocity * delta
	
	
func on_collided(body):
	if body.has_method("take_damage"):
		Signals.hitbox_collided.emit( 
		{
			"target_rid": body.rid,
			"hitbox_entity_model": entity_model,
			"dealer_rid": caster,
			"target_position": body.global_position,
			"damage_position": global_position,
			"damage_scale": 0.6,
		})
		#prints("Hitbox collision detected with", body)
		lifetime_end()
	

func lifetime_end():
	if lifetime_ended:
		return
	lifetime_ended = true
	#prints(rid, "freed")
	Signals.entity_freed.emit({"target_rid": rid})
