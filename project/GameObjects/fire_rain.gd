extends Node3D
class_name FireRain


# TODO: Switch to physics implementation from tween
@onready var bolt_scene = preload("res://GameObjects/fire_rain_bolt.tscn")
var bolts: Dictionary = {}
var valid_enemies: Array[Vector3]
var attack_range := 100.0
var speed = 15.0
var hit_range = 5.0
@export var num_bolts = 5
var bolts_instantiated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.map_updated.connect(_on_map_updated)
	Signals.spell_cast.connect(_on_spell_cast)
	Signals.spell_node_spawned.connect(_on_spell_spawned)
	get_tree().create_timer(3).timeout.connect(activate)

func activate():
	if not bolts_instantiated:
		for i in range(num_bolts):
			Signals.spell_cast.emit({"spell_type": "fire_bolt"})
			bolts_instantiated = true
	else:
		for rid in bolts.keys():
			if not rid in Core.map.nodes:
				bolts.erase(rid)
		if bolts.is_empty():
			bolts_instantiated = false
			activate()
	get_tree().create_timer(3).timeout.connect(activate)

# Iterate through entity map to find adjacent enemies
# assigns rid to bolt
func set_target_pos(rid):
	if len(valid_enemies) <= 0:
		return false
	var idx = randi_range(0, len(valid_enemies) - 1)
	bolts[rid] = GunSlotController.inaccuratize_vector(valid_enemies[idx], 80)
	return true
	
# starts transform with random facing
# tween bolt speed and sfx pitch up
func tween_bolt(bolt: SpellHitbox):
	var tween := get_tree().create_tween()
	var target_pos = bolts[bolt.rid]
	var rel_pos = target_pos - bolt.position
	# target_pos += Core.map.entities[bolts[bolt]].metadata.movement_speed * float(rel_pos.length())/speed * Vector3.FORWARD * Core.map.entities[bolts[bolt]].transform.basis
	var control1 = Vector3.UP * bolt.basis * speed
	var control2 = control1 * 2
	var lifetime = float(rel_pos.length())/speed * randf_range(0.9, 1)
	bolt.lifetime = lifetime
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_method(func(t):
		if not bolt:
			tween.kill()
			return
		_bezier_bolt(t, bolt, control1, control2, target_pos), 
		0.0, 1.2, lifetime)
	tween.play()


func _bezier_bolt(t:float, bolt:Node3D, control1, control2, target_pos:Vector3):
	var new_pos = bolt.position.bezier_interpolate(
		control1, control2, target_pos, 
		t)
	bolt.transform.basis = bolt.transform.looking_at(new_pos).basis
	bolt.position = new_pos

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
				var target_pos = entities[key].position
				if entities[key].metadata.eye_pos:
					target_pos += entities[key].metadata.eye_pos
				valid_enemies.append(target_pos)

func _on_spell_spawned(payload=null):
	if payload["rid"] in bolts:
		var bolt = Core.map.nodes[payload["rid"]]
		set_target_pos(payload["rid"])
		tween_bolt(bolt)

func _on_spell_cast(payload=null):
	if "spell_type" not in payload or payload["spell_type"] != "fire_bolt":
		return
	_add_spell_on_map(GunSlotController.inaccuratize_vector(
		Vector3.UP * transform.basis, 20))

func _add_spell_on_map(throw_vector):
	var entity = EntityModel.new_entity(
		EntityMetadataModel.EntityType.FIRE_BALL)
	var payload = {
		"rid" : entity.rid,
		"position" : position + throw_vector,
		"linear_velocity" : Vector3.ZERO,
		"entity_model" : entity,
		"caster": Core.map.player_rid,
	}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	bolts[entity.rid] = null
	Signals.spell_entity_added.emit(payload)
	return entity.rid
