extends Node2D
class_name Home

@export var label_oro_cassaforte: Label


func _ready() -> void:
	ManagerRaccolata.oro_cassaforte_aggiornato.connect(_aggiorna_oro)
	_aggiorna_oro(ManagerRaccolata.oro_cassaforte)


func _aggiorna_oro(valore: int) -> void:
	if label_oro_cassaforte:
		label_oro_cassaforte.text = str(valore)


func GiocaArena(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		SceneManager.vai_all_arena()
