extends Node3D
class_name FireRain


# TODO: Switch to physics implementation from tween
@onready var bolt_scene = preload("res://GameObjects/fire_rain_bolt.tscn")
@export var bolts: Dictionary = {}
var valid_enemies: Array[int]
var attack_range := 100.0
var speed = 15.0
var hit_range = 5.0
@export var num_bolts = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.map_updated.connect(_on_map_updated)
	
	for i in range(num_bolts):
		var new_bolt: Node3D = bolt_scene.instantiate()
		add_child(new_bolt)
		bolts[new_bolt] = -1
	get_tree().create_timer(3).timeout.connect(activate)
	for bolt in bolts.keys():
		deactivate_bolt(bolt)

# for each bolt with a target, rotate to face target and move at speed
func _physics_process(delta):
	check_collisions(delta)

func activate():
	print("FireRain Activated")
	for bolt in bolts.keys():
		if bolts[bolt] != -1:
			continue
		get_tree().create_timer(randf_range(
			0.01, 0.01 + 0.002 * num_bolts)).timeout.connect(
		func():
			if not set_target(bolt):
				get_tree().create_timer(1).timeout.connect(activate)
				return
			bolt.show()
			bolt.transform = transform
			bolt.rotation = GunSlotController.inaccuratize_vector(
				Vector3.UP*90, 20)
			tween_bolt(bolt)
		)
	get_tree().create_timer(1).timeout.connect(activate)
	
# Iterate through entity map to find adjacent enemies
# assigns rid to bolt
func set_target(bolt: Node3D):
	if len(valid_enemies) <= 0:
		return false
	var idx = randi_range(0, len(valid_enemies)-1)
	bolts[bolt] = valid_enemies[idx]
	return true
	
# starts transform with random facing
# tween bolt speed and sfx pitch up
func tween_bolt(bolt: Node3D):
	var tween := get_tree().create_tween()
	var target_pos = Core.map.entities[bolts[bolt]].position - position
	if Core.map.entities[bolts[bolt]].metadata.eye_pos:
		target_pos += Core.map.entities[bolts[bolt]].metadata.eye_pos
	var rel_pos = target_pos - bolt.position
	# target_pos += Core.map.entities[bolts[bolt]].metadata.movement_speed * float(rel_pos.length())/speed * Vector3.FORWARD * Core.map.entities[bolts[bolt]].transform.basis
	var control1 = Vector3.UP * bolt.basis * speed
	var control2 = control1 * 2
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_method(func(t):
		if bolts[bolt] == -1:
			tween.kill()
		_bezier_bolt(t, bolt, control1, control2, target_pos)
		, 0.0, 1.0, 
		float(rel_pos.length())/speed * randf_range(0.9, 1))
	tween.play()
	tween.finished.connect(deactivate_bolt.bind(bolt))
	

func _bezier_bolt(t:float, bolt:Node3D, control1, control2, target_pos:Vector3):
	var new_pos = bolt.position.bezier_interpolate(
		control1, control2, target_pos, 
		t)
	bolt.transform.basis = bolt.transform.looking_at(new_pos).basis
	bolt.position = new_pos

# run short raycast forwards from center of bolt to find targets
# emit signal and deactivate on valid result
func check_collisions(delta):
	for bolt in bolts.keys():
		if bolts[bolt] == -1 or not Core.map.entities.has(bolts[bolt]) or Core.map.entities[bolts[bolt]].is_queued_for_deletion():
			continue
		var origin = bolt.global_position
		var cast_vector = -bolt.get_global_transform().basis.z.normalized() * delta * speed
		var end = origin + cast_vector
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result and result["collider"]:
			if result["collider"].has_method("take_damage") and !result["collider"].is_queued_for_deletion():
				result["collider"].take_damage(
					100, 1, Core.map.player_rid, result["position"])
			deactivate_bolt(bolt)
		elif (Core.map.entities[bolts[bolt]].position - bolt.position).length() < hit_range:
			Core.map.entities[bolts[bolt]].take_damage(
					100, 1, Core.map.player_rid, Core.map.entities[bolts[bolt]].position)
			deactivate_bolt(bolt)

func _on_map_updated(payload=null):
	var entities = Core.map.entities
	valid_enemies = []
	var pos = global_position
	var closest = null
	for key in entities.keys():
		if entities[key].type == EntityModel.EntityType.enemy:
			pos.y = entities[key].position.y
			var relative_pos = entities[key].position - pos
			if not closest or relative_pos.length() < closest.length():
				closest = entities[key].position
			if relative_pos.length() <= attack_range:
				valid_enemies.append(key)

func deactivate_bolt(bolt):
	bolt.hide()
	bolts[bolt] = -1
