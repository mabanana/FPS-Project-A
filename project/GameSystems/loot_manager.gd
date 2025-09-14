class_name LootManager

const LOOT_VELOCITY = 10

var loot_classes: Dictionary
enum LootClass {
	NONE,
	TEST_SCENE_1_DROP,
	WEAPON_BASE_LIST,
}

func _init():
	var loot_class_json = _load_json("res://GameSystems/loot_classes.json")
	for lc in loot_class_json.loot_classes:
		loot_classes[LootClass[lc.loot_class]] = lc.items
	Signals.entity_died.connect(_on_entity_died)

func drop_loot(loot_class: LootClass, target_name: String, target_position: Vector3):
	if loot_class:
		var loot_table = get_loot_table(loot_class)
		var loot = Randomizer.roll_loot(loot_table)
		if loot["type"] == "LootClass":
			drop_loot(LootClass[loot["name"]], target_name, target_position)
			return
		prints("Loot Dropped by", target_name, loot["name"])
		if loot["type"] == "Gun":
			var entity =  EntityModel.new_entity(EntityMetadataModel.EntityType.GUN_ON_FLOOR)
			var gun_type = GunMetadataModel.GunType[loot["name"]]
			var gun_rid = Core.services.generate_rid()
			var gun_model = GunModel.new_with_full_ammo(gun_rid, gun_type)
			var linear_velocity = GunSlotController.inaccuratize_vector(Vector3.UP, 60) * LOOT_VELOCITY
			var angular_velocity = linear_velocity.cross(Vector3.UP).normalized() * LOOT_VELOCITY
			
			var payload = {
				"rid" : Core.services.generate_rid(),
				"linear_velocity" : linear_velocity,
				"angular_velocity" : angular_velocity,
				"position" : target_position,
				"gun_model" : gun_model,
				"entity_model" : entity,
			}
			Signals.gun_dropped.emit(payload)
	else:
		print("no loot from this one.")


func get_loot_table(loot_class: LootClass):
	var loot_table = {}
	for item in loot_classes[loot_class]:
		loot_table[item] = item["weight"]
	return loot_table
	
func _load_json(path: String):
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var parsed_json = JSON.parse_string(content)
	if parsed_json:
		return parsed_json

func _on_entity_died(payload = null):
	drop_loot(payload["loot_class"], payload["target_name"], payload["target_position"])
