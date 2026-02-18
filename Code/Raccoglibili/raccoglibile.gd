extends Area2D

enum TipoRaccoglibile { ORO, EXP, BISTECCA }

@export var tipo: TipoRaccoglibile
@export var valore: int = 1

var _animazione_per_tipo := {
	TipoRaccoglibile.ORO: "OroRaccolto",
	TipoRaccoglibile.EXP: "ExpRaccolta",
}

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_area: Area2D) -> void:
	ManagerRaccolata.raccogli(tipo, valore)
	var marker := get_node_or_null("Marker2D") as Marker2D
	if marker and _animazione_per_tipo.has(tipo):
		var pos_globale := marker.global_position
		remove_child(marker)
		get_tree().current_scene.add_child(marker)
		marker.global_position = pos_globale
		MostraValore.crea(marker, valore, _animazione_per_tipo[tipo])
	queue_free()
