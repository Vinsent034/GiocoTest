extends Area2D
class_name HurtBox

signal ricevuto_colpo(hit_box: HitBox)

@export var cooldown_colpo: float = 0.2
var _hitbox_in_cooldown: Dictionary = {}


func _ready() -> void:
	area_entered.connect(_su_area_entrata)


func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	for area in get_overlapping_areas():
		_su_area_entrata(area)


func _su_area_entrata(area: Area2D) -> void:
	if not area is HitBox:
		return
	if _hitbox_in_cooldown.has(area.get_instance_id()):
		return
	ricevuto_colpo.emit(area)
	var proprietario = get_parent()
	if proprietario.has_method("subisci_danno"):
		proprietario.subisci_danno(area.danno, area.critico)
	var id := area.get_instance_id()
	_hitbox_in_cooldown[id] = true
	get_tree().create_timer(cooldown_colpo).timeout.connect(
		func(): _hitbox_in_cooldown.erase(id)
	)
