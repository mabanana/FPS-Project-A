extends Control

@export var vbox: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	for stat in PlayerModel.Stat.keys():
		var hbox = HBoxContainer.new()
		for type in ["Add", "Mult"]:
			var spinbox = SpinBox.new()
			spinbox.prefix = stat.capitalize() + " " + type.capitalize()
			spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if type == "Mult":
				spinbox.suffix = "%"
				spinbox.step = 0.1
				spinbox.value_changed.connect(func(value):
						Core.player.stat_mult_dict[PlayerModel.Stat[stat]] = value
						Signals.core_changed.emit()
				)
			elif type == "Add":
				spinbox.value_changed.connect(func(value):
						Core.player.stat_add_dict[PlayerModel.Stat[stat]] = value
						Signals.core_changed.emit()
				)
			hbox.add_child(spinbox)
		vbox.add_child(hbox)
		hide()
		Signals.mouse_capture_toggled.connect(func(payload=null):
			visible = Input.mouse_mode == Input.MouseMode.MOUSE_MODE_VISIBLE)
