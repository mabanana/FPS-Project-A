class_name Randomizer

static var TEST_LOOT_TABLE := {
		"common": 70,
		"uncommon": 20,
		"rare": 10
		}

static func roll_loot(table: Dictionary) -> String:
	var weight_total = 0
	for loot in table.keys():
		weight_total += table[loot]
	var roll_result = randi_range(0,weight_total)
	for loot in table.keys():
		roll_result -= table[loot]
		if roll_result <= 0:
			return loot
	push_error("Failed loot probability roll.")
	return ""
