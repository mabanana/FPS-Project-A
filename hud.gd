extends Control
class_name hud_controller

var core: CoreModel
var core_changed: Signal

func update():
	%GunName.text = str(core.inventory.active_gun.metadata.name) if core.inventory.active_gun else ""
	%Total.text = str(core.inventory.ammo)
	%Magazine.text = str(core.inventory.active_gun.mag_curr) if core.inventory.active_gun else "0"
	%HpValue.text = str(core.player.hp)
	%ReloadIndicator.modulate.a = int(core.player.reloading)
	%ProgressBar.max_value = core.inventory.active_gun.metadata.mag_size if core.inventory.active_gun else 0
	%ProgressBar.value = core.inventory.active_gun.mag_curr if core.inventory.active_gun else 0
	
func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	update()
