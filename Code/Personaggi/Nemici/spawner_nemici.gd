extends Node
class_name SpawnerNemici

# --- Riferimento alla mappa (letto da Global) ---
var mappa: Mappa

# --- Punti di spawn ---
@export var punti_spawn: Array[Marker2D] = []
@export var raggio_spawn: float = 40.0
@export var distanza_minima_player: float = 120.0

# --- Stato interno ---
var _coda: Array[CartaNemico] = []   # nemici da spawnare in ordine casuale
var _vivi: int = 0                   # nemici attualmente in arena


func _ready() -> void:
	Global.rilascio_id.connect(_su_nemico_morto)


func reinizializza() -> void:
	mappa = Global.RiferiemntoMappa
	if mappa == null:
		return
	_vivi = 0
	_coda.clear()


# Chiamata da QuestArena dopo aver costruito la distribuzione
func inizializza(coda: Array[CartaNemico]) -> void:
	_coda = coda
	_coda.shuffle()
	call_deferred("_avvia")


func _avvia() -> void:
	if mappa == null:
		return
	# Spawna fino al limite massimo in arena
	while _vivi < mappa.Max_nemici_per_dentro_arena and not _coda.is_empty():
		_spawna_prossimo()


func _spawna_prossimo() -> void:
	if _coda.is_empty():
		return
	var carta: CartaNemico = _coda.pop_front()
	if carta == null or carta.ScenaNemico == null:
		return
	var nemico: Nemico = carta.ScenaNemico.instantiate()
	nemico.IDnemico = carta.ID_nemico
	get_tree().current_scene.add_child(nemico)
	nemico.global_position = _posizione_valida()
	_vivi += 1


func _su_nemico_morto(_id: int) -> void:
	_vivi = max(0, _vivi - 1)
	# Spawna il prossimo se ce ne sono ancora in coda
	if not _coda.is_empty():
		_spawna_prossimo()


# --- Posizione spawn ---

func _posizione_valida() -> Vector2:
	if punti_spawn.is_empty():
		return Vector2.ZERO
	var player: Node2D = get_tree().get_first_node_in_group("Player")
	var tentativi := 10
	while tentativi > 0:
		var marker: Marker2D = punti_spawn[randi() % punti_spawn.size()]
		var offset := Vector2(randf_range(-raggio_spawn, raggio_spawn), randf_range(-raggio_spawn, raggio_spawn))
		var pos := marker.global_position + offset
		if not player or pos.distance_to(player.global_position) >= distanza_minima_player:
			return pos
		tentativi -= 1
	return punti_spawn[0].global_position
