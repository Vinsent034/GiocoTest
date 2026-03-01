extends Node2D

@export var mappe: Array[PackedScene] = []
@export var Livello: int = 1
@export var LivelloL: Label 
var _indice_corrente: int = 0
var _mappa_nodo: Mappa = null


func _ready() -> void:
	_mappa_nodo = get_node_or_null("Mappa")
	Global.AvviaTween.connect(_su_avvia_tween)


func _su_avvia_tween() -> void:
	var transizione := get_node_or_null("TransizioneVerticale") as TransizioneVerticale
	if transizione:
		await transizione.tween_completato
	_carica_prossima_mappa()
	if transizione:
		transizione.esci()


func _carica_prossima_mappa() -> void:
	if mappe.is_empty():
		return

	# Rimuove la mappa attuale
	if _mappa_nodo:
		_mappa_nodo.queue_free()
		_mappa_nodo = null

	# Avanza all'indice successivo (ciclico)
	_indice_corrente = (_indice_corrente + 1) % mappe.size()

	# Istanzia la nuova mappa (il suo _ready aggiornerà Global.RiferiemntoMappa)
	var nuova_mappa: Mappa = mappe[_indice_corrente].instantiate()
	add_child(nuova_mappa)
	_mappa_nodo = nuova_mappa
	Global.mappa_cambiata.emit()
	Livello +=1 
	LivelloL.text = "Piano: " + str(Livello)
