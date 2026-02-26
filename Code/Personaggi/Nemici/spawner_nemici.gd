extends Node

# --- Scene nemici (fallback) ---
@export var scena_inseguitore: PackedScene
@export var scena_lanciatore: PackedScene
@export var scena_scattatore: PackedScene
@export var scena_base: PackedScene

# --- Nemici disponibili dall'arena ---
var nemici_disponibili_arena: Array[PackedScene] = []

# --- Configurazione wave ---
@export var nemici_wave_iniziale: int = 5        # nemici nella wave 1
@export var incremento_per_wave: int = 3         # nemici aggiunti ad ogni wave
@export var pausa_tra_wave: float = 3.0          # secondi di attesa tra una wave e l'altra

# --- Punti di spawn ---
@export var punti_spawn: Array[Marker2D] = []
@export var raggio_spawn: float = 40.0
@export var distanza_minima_player: float = 120.0

# --- Stato ---
var wave_corrente: int = 0
var nemici_vivi: int = 0
var _in_pausa: bool = false
var _timer_pausa: float = 0.0

# --- Segnali ---
signal wave_iniziata(numero: int)
signal wave_completata(numero: int)


func _su_arena_pronta(arena: Node) -> void:
	# Leggi tutte le scene nemiche dall'arena (scena_nemico_1 a scena_nemico_8)
	nemici_disponibili_arena.clear()
	
	for i in range(1, 9):
		var nome_proprieta = "scena_nemico_" + str(i)
		if arena.has_property(nome_proprieta):
			var scena = arena.get(nome_proprieta)
			if scena is PackedScene:
				nemici_disponibili_arena.append(scena)
	
	call_deferred("_avvia_wave")


func _ready() -> void:
	# Connettiti al segnale della mappa per ricevere i nemici disponibili
	var mappa = get_tree().get_first_node_in_group("Arena")
	if not mappa:
		mappa = get_parent()
	
	if mappa and mappa.has_signal("arena_pronta"):
		mappa.arena_pronta.connect(_su_arena_pronta)
	else:
		# Se non c'è segnale, usa le export locali
		call_deferred("_avvia_wave")


func _process(delta: float) -> void:
	if _in_pausa:
		_timer_pausa -= delta
		if _timer_pausa <= 0.0:
			_in_pausa = false
			_avvia_wave()


# --- Wave ---

func _avvia_wave() -> void:
	wave_corrente += 1
	var totale := nemici_wave_iniziale + (wave_corrente - 1) * incremento_per_wave

	emit_signal("wave_iniziata", wave_corrente)

	for i in totale:
		var scena := _scegli_scena()
		if not scena:
			continue
		var nemico: Nemico = scena.instantiate()
		get_parent().add_child(nemico)
		nemico.global_position = _posizione_valida()
		nemico.morto.connect(_su_nemico_morto, CONNECT_ONE_SHOT)
		nemici_vivi += 1


func _su_nemico_morto() -> void:
	nemici_vivi = max(0, nemici_vivi - 1)
	if nemici_vivi == 0 and not _in_pausa:
		emit_signal("wave_completata", wave_corrente)
		_in_pausa = true
		_timer_pausa = pausa_tra_wave


# --- Selezione scena ---

func _scegli_scena() -> PackedScene:
	# Usa i nemici dell'arena se disponibili, altrimenti fallback alle export locali
	var disponibili: Array[PackedScene] = []
	
	if not nemici_disponibili_arena.is_empty():
		disponibili = nemici_disponibili_arena.duplicate()
	else:
		# Fallback: usa le export dello spawner
		if scena_inseguitore:
			disponibili.append(scena_inseguitore)
		if scena_lanciatore:
			disponibili.append(scena_lanciatore)
		if scena_scattatore:
			disponibili.append(scena_scattatore)
		if scena_base:
			disponibili.append(scena_base)
	
	if disponibili.is_empty():
		return null
	return disponibili[randi() % disponibili.size()]


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
