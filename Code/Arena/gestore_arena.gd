extends Node2D
class_name ArenaGame


const INTERVALLO_ISOLOTTO: int = 5

@export var mappe: Array[PackedScene] = []
@export var isolotto: PackedScene
@export var Livello: int = 1
@export var LivelloL: Label
@export var ui_nemici: Control

var _indice_corrente: int = 0
var _mappa_nodo: Node = null
var caricato_da_file: bool = false


func _ready() -> void:
	_mappa_nodo = get_node_or_null("Mappa")
	Global.AvviaTween.connect(_su_avvia_tween)
	Global.gestore_arena = self
	if not SaveManager.esiste():
		ManagerRaccolata.oro_totale = 0
		ManagerRaccolata.exp_totale = 0
	call_deferred("_carica_da_salvataggio")


func _carica_da_salvataggio() -> void:
	if not SaveManager.esiste():
		return
	caricato_da_file = true
	await get_tree().process_frame
	SaveManager.carica(self)
	# Rimuove la mappa di default della scena
	if _mappa_nodo:
		_mappa_nodo.queue_free()
		_mappa_nodo = null
	# Istanzia la mappa corretta per il livello salvato
	if Livello % INTERVALLO_ISOLOTTO == 0 and isolotto:
		if ui_nemici:
			ui_nemici.visible = false
		_mappa_nodo = isolotto.instantiate()
		add_child(_mappa_nodo)
		# Nessun nemico sull'isolotto: svuota spawner e rimuovi nemici già spawnati
		var spawner := get_node_or_null("SpaunerNemici") as SpawnerNemici
		if spawner:
			spawner.reinizializza()
		for nemico in get_tree().get_nodes_in_group("Nemici"):
			nemico.queue_free()
	else:
		if ui_nemici:
			ui_nemici.visible = true
		var nuova_mappa: Mappa = mappe[_indice_corrente].instantiate()
		add_child(nuova_mappa)
		_mappa_nodo = nuova_mappa
		Global.mappa_cambiata.emit()


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

	for r in get_tree().get_nodes_in_group("Raccoglibili"):
		r.queue_free()
	if _mappa_nodo:
		_mappa_nodo.queue_free()
		_mappa_nodo = null

	Livello += 1
	LivelloL.text = "Piano: " + str(Livello)

	# Ogni 5 livelli carica l'isolotto invece di una mappa normale
	if Livello % INTERVALLO_ISOLOTTO == 0 and isolotto:
		if ui_nemici:
			ui_nemici.visible = false
		_mappa_nodo = isolotto.instantiate()
		add_child(_mappa_nodo)
		return

	# Carica la prossima mappa normale (ciclica)
	if ui_nemici:
		ui_nemici.visible = true
	_indice_corrente = (_indice_corrente + 1) % mappe.size()
	var nuova_mappa: Mappa = mappe[_indice_corrente].instantiate()
	add_child(nuova_mappa)
	_mappa_nodo = nuova_mappa
	Global.mappa_cambiata.emit()
