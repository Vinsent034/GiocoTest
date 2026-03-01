extends Nemico
class_name NemicoScattatore

# --- Parametri carica ---
@export var durata_inseguimento_prima_carica: float = 3.0   # secondi di run prima di prepararsi
@export var durata_preparazione: float = 1.2                # secondi di puntamento fermo
@export var distanza_carica: float = 150.0                  # pixel percorsi durante l'avanzata
@export var velocita_carica: float = 300.0                  # velocità durante l'avanzata

# --- Timer (nodi) ---
@export var timer_inseguimento: Timer
@export var timer_preparazione: Timer

# --- Stato macchina ---
enum StatoScattatore { IDLE, RUN, PREPARAZIONE, AVANZATA }
var _stato: StatoScattatore = StatoScattatore.IDLE

# --- Variabili interne ---
var _direzione_carica: Vector2 = Vector2.ZERO
var _distanza_percorsa: float = 0.0


func _ready() -> void:
	super._ready()
	_abilita_hitbox()

	# Connetti i segnali dei timer
	if timer_inseguimento:
		timer_inseguimento.timeout.connect(_su_timer_inseguimento_scaduto)
	if timer_preparazione:
		timer_preparazione.timeout.connect(_su_timer_preparazione_scaduto)


func _physics_process(delta: float) -> void:
	if _in_comparsa:
		return
	_cerca_bersaglio()

	match _stato:
		StatoScattatore.IDLE:
			_gestisci_idle_scattatore()
		StatoScattatore.RUN:
			_gestisci_run()
		StatoScattatore.PREPARAZIONE:
			_gestisci_preparazione()
		StatoScattatore.AVANZATA:
			_gestisci_avanzata(delta)


# --- Gestione stati ---

func _gestisci_idle_scattatore() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_riproduci_animazione("Idle")

	if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
		_cambia_stato_scattatore(StatoScattatore.RUN)


func _gestisci_run() -> void:
	if not bersaglio:
		_cambia_stato_scattatore(StatoScattatore.IDLE)
		return

	if _distanza_dal_bersaglio() > raggio_inseguimento:
		_cambia_stato_scattatore(StatoScattatore.IDLE)
		return

	if _distanza_dal_bersaglio() < 5.0:
		velocity = Vector2.ZERO
		move_and_slide()
		_riproduci_animazione("Idle")
		return

	var direzione := global_position.direction_to(bersaglio.global_position)
	velocity = direzione * velocita + _calcola_forza_separazione()
	move_and_slide()

	if sprite and abs(direzione.x) > 0.1:
		sprite.flip_h = direzione.x < 0.0

	_riproduci_animazione("Run")


func _gestisci_preparazione() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	# Continua a puntare verso il player mentre il timer scorre
	if bersaglio and sprite:
		var dx := bersaglio.global_position.x - global_position.x
		if abs(dx) > 8.0:
			sprite.flip_h = dx < 0.0

	_riproduci_animazione("Guard")


func _gestisci_avanzata(delta: float) -> void:
	var spostamento := _direzione_carica * velocita_carica * delta
	velocity = _direzione_carica * velocita_carica
	move_and_slide()
	_riproduci_animazione("Carica")

	_distanza_percorsa += spostamento.length()

	if _distanza_percorsa >= distanza_carica:
		_termina_avanzata()


# --- Cambio stato ---

func _cambia_stato_scattatore(nuovo_stato: StatoScattatore) -> void:
	_stato = nuovo_stato

	match nuovo_stato:
		StatoScattatore.IDLE:
			if hit_box:
				hit_box.danno = potenza_attacco
			_ferma_timer_inseguimento()
			_ferma_timer_preparazione()

		StatoScattatore.RUN:
			if hit_box:
				hit_box.danno = potenza_attacco
			_ferma_timer_preparazione()
			_avvia_timer_inseguimento()

		StatoScattatore.PREPARAZIONE:
			if hit_box:
				hit_box.danno = potenza_attacco
			_ferma_timer_inseguimento()
			_avvia_timer_preparazione()

		StatoScattatore.AVANZATA:
			# Salva la direzione verso il player all'ultimo momento
			if bersaglio:
				_direzione_carica = global_position.direction_to(bersaglio.global_position)
			_distanza_percorsa = 0.0
			if hit_box:
				hit_box.danno = potenza_attacco * 2


# --- Callback timer ---

func _su_timer_inseguimento_scaduto() -> void:
	if _stato == StatoScattatore.RUN:
		_cambia_stato_scattatore(StatoScattatore.PREPARAZIONE)


func _su_timer_preparazione_scaduto() -> void:
	if _stato == StatoScattatore.PREPARAZIONE:
		_cambia_stato_scattatore(StatoScattatore.AVANZATA)


# --- Fine avanzata ---

func _termina_avanzata() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	# Controlla se il player è ancora nel raggio
	if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
		_cambia_stato_scattatore(StatoScattatore.RUN)
	else:
		_cambia_stato_scattatore(StatoScattatore.IDLE)


# --- Utilità timer ---

func _avvia_timer_inseguimento() -> void:
	if timer_inseguimento:
		timer_inseguimento.wait_time = durata_inseguimento_prima_carica
		timer_inseguimento.start()


func _ferma_timer_inseguimento() -> void:
	if timer_inseguimento:
		timer_inseguimento.stop()


func _avvia_timer_preparazione() -> void:
	if timer_preparazione:
		timer_preparazione.wait_time = durata_preparazione
		timer_preparazione.start()


func _ferma_timer_preparazione() -> void:
	if timer_preparazione:
		timer_preparazione.stop()


# --- Override: blocca la macchina a stati del padre ---

func _gestisci_idle() -> void:
	pass  # gestito da _gestisci_idle_scattatore


func _gestisci_inseguimento() -> void:
	pass  # non usato


func _gestisci_attacco() -> void:
	pass  # non usato