extends Area2D
class_name HitBox

# Danno inflitto da questa HitBox
@export var danno: int = 10
var critico: bool = false

# Segnale emesso quando colpisce una HurtBox
signal colpito(hurt_box: Area2D)


func _ready() -> void:
	area_entered.connect(_su_area_entrata)


func _su_area_entrata(area: Area2D) -> void:
	#print("[HitBox] area_entered: ", area.name, " is HurtBox: ", area is HurtBox, " parent: ", area.get_parent().name)
	if area is HurtBox:
		colpito.emit(area)
