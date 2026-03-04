extends Node

const ARENA := preload("res://Code/Arena/arena.tscn")
const HOME := preload("res://Code/Home/home.tscn")
const TRANSIZIONE := preload("res://Code/Transizioni/transizione_verticale.tscn")


func vai_all_arena() -> void:
	_cambia_scena(ARENA)


func vai_alla_home() -> void:
	_cambia_scena(HOME)


func _cambia_scena(scena: PackedScene) -> void:
	var transizione: TransizioneVerticale = TRANSIZIONE.instantiate()
	get_tree().root.add_child(transizione)
	transizione.entra()
	await transizione.tween_completato
	get_tree().change_scene_to_packed(scena)
	transizione.esci()
	await get_tree().process_frame
	transizione.queue_free()
