extends Node2D

@export var raggio: float = 60.0
@export var velocita_rotazione: float = 120.0  # gradi/secondo

var _angolo: float = 0.0


func _process(delta: float) -> void:
	_angolo += velocita_rotazione * delta
	var i := 0
	for figlio in get_children():
		if not figlio is OggettiEquipagiabbiliBonus:
			continue
		var angolo_figlio := deg_to_rad(_angolo + i * (360.0 / get_child_count()))
		figlio.position = Vector2(cos(angolo_figlio), sin(angolo_figlio)) * raggio
		i += 1
