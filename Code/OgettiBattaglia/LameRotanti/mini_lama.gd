extends Node2D
class_name OggettiEquipagiabbiliBonus

@export var danno: int = 10

@onready var hit_box: HitBox = $HitBox


func _ready() -> void:
	hit_box.danno = danno
