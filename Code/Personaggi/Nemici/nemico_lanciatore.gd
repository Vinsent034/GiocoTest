extends Nemico
class_name NemicoLanciatore

@export var durata_wandering: float = 2.0
@export var velocita_wandering: float = 50.0

# Variabili specifiche del tiratore
var velocita_proiettile: float = 350.0
var raggio_tiro: float = 400.0
var cadenza_fuoco: float = 1.5
var numero_colpi: int = 1
var angolo_dispersione: float = 0.0
var tempo_preparazione: float = 0.3

var _direzione_wandering: Vector2 = Vector2.ZERO
var _timer_wandering: float = 0.0
var _in_wandering: bool = false



func _physics_process(delta: float) -> void:
	if _in_wandering:
		_gestisci_wandering(delta)
		return
	super._physics_process(delta)


# --- Override stati ---

func _gestisci_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_riproduci_animazione("Idle")

	if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
		_cambia_stato(Stato.ATTACCO)


func _gestisci_inseguimento() -> void:
	_cambia_stato(Stato.ATTACCO)


func _cambia_stato(nuovo_stato: Stato) -> void:
	if nuovo_stato == Stato.ATTACCO and bersaglio and sprite:
		var dx := bersaglio.global_position.x - global_position.x
		if abs(dx) > 0.1:
			sprite.flip_h = dx < 0.0
	super._cambia_stato(nuovo_stato)


func _gestisci_attacco() -> void:
	velocity = Vector2.ZERO
	move_and_slide()


# --- Lancio freccia ---

func _freccia_libera() -> FrecciaNemico:
	for figlio in get_children():
		if figlio is FrecciaNemico and figlio.stato == FrecciaNemico.Stato.LIBERA:
			return figlio
	return null


func _lancia_freccia() -> void:
	if not bersaglio:
		return
	var freccia := _freccia_libera()
	if not freccia:
		return
	var direzione_tiro := global_position.direction_to(bersaglio.global_position)
	freccia.spara(direzione_tiro, potenza_attacco)


# --- Wandering ---

func _avvia_wandering() -> void:
	_in_wandering = true
	_timer_wandering = durata_wandering
	var angolo := randf() * TAU
	_direzione_wandering = Vector2(cos(angolo), sin(angolo))
	_riproduci_animazione("Run")


func _gestisci_wandering(delta: float) -> void:
	_timer_wandering -= delta
	velocity = _direzione_wandering * velocita_wandering + _calcola_forza_separazione()
	move_and_slide()

	if sprite and abs(_direzione_wandering.x) > 0.1:
		sprite.flip_h = _direzione_wandering.x < 0.0

	if _timer_wandering <= 0.0:
		_in_wandering = false
		_cambia_stato(Stato.IDLE)


# --- Animazione finita ---

func _su_animazione_finita(nome_animazione: StringName) -> void:
	if nome_animazione == &"Attack1":
		_lancia_freccia()
		_avvia_wandering()
