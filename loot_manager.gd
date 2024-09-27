class_name LootManager

var core: CoreModel
var core_changed: Signal
var contexts


var loot_classes: Dictionary
enum LootClass {
	TEST_SCENE_1_DROP,
	WEAPON_BASE_LIST,
}

func _init():
	var loot_class_json = _load_json("res://loot_classes.json")
	for lc in loot_class_json.loot_classes:
		loot_classes[LootClass[lc.loot_class]] = lc.items

func drop_loot(loot_class: LootClass, target_name: String):
	var loot_table = get_loot_table(loot_class)
	var loot = Randomizer.roll_loot(loot_table)
	if loot in LootClass.keys():
		drop_loot(LootClass[loot], target_name)
		return
	prints("Loot Dropped by", target_name, loot)

func get_loot_table(loot_class: LootClass):
	var loot_table = {}
	for item in loot_classes[loot_class]:
		loot_table[item["name"]] = item["weight"]
	return loot_table
	
func _load_json(path: String):
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var parsed_json = JSON.parse_string(content)
	if parsed_json:
		return parsed_json

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == contexts.entity_died:
		drop_loot(payload["loot_class"], payload["target_name"])
