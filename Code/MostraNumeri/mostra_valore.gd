extends Label
class_name MostraValore

const SCENA := preload("res://Code/MostraNumeri/MostraValore.tscn")

@onready var animazione: AnimationPlayer = $AnimationPlayer

static func crea(marker: Marker2D, valore: int, tipo: String) -> void:
	var popup = SCENA.instantiate()
	marker.add_child(popup)
	popup.mostra(valore, tipo)

func mostra(valore: int, tipo: String) -> void:
	text = str(valore)
	animazione.play(tipo)
