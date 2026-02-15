extends CharacterBody2D
class_name Nemico

# --- Variabili base (sovrascrivibili dalle classi figlie) ---
@export var velocita: float = 80.0
@export var potenza_attacco: int = 5
@export var salute_massima: int = 50
@export var raggio_inseguimento: float = 200.0
@export var raggio_attacco: float = 30.0
@export var ritardo_attacco: float = 1.0

var salute: int
var _timer_attacco: float = 0.0

# --- Riferimenti ---
@export var animatore: AnimationPlayer
@export var sprite: Sprite2D
var bersaglio: Player = null

# --- Macchina a stati ---
enum Stato { IDLE, INSEGUIMENTO, ATTACCO }
var stato_corrente: Stato = Stato.IDLE


func _ready() -> void:
	salute = salute_massima
	if animatore:
		animatore.animation_finished.connect(_su_animazione_finita)


func _physics_process(delta: float) -> void:
	_aggiorna_timer(delta)
	_cerca_bersaglio()

	match stato_corrente:
		Stato.IDLE:
			_gestisci_idle()
		Stato.INSEGUIMENTO:
			_gestisci_inseguimento()
		Stato.ATTACCO:
			_gestisci_attacco()


# --- Gestione stati ---

func _gestisci_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_riproduci_animazione("Idle")

	if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
		_cambia_stato(Stato.INSEGUIMENTO)


func _gestisci_inseguimento() -> void:
	if not bersaglio:
		_cambia_stato(Stato.IDLE)
		return

	var distanza := _distanza_dal_bersaglio()

	if distanza <= raggio_attacco and _timer_attacco <= 0.0:
		_cambia_stato(Stato.ATTACCO)
		return

	if distanza > raggio_inseguimento:
		_cambia_stato(Stato.IDLE)
		return

	# Muovi verso il bersaglio
	var direzione := global_position.direction_to(bersaglio.global_position)
	velocity = direzione * velocita
	move_and_slide()

	# Gira lo sprite
	if sprite and direzione.x != 0.0:
		sprite.flip_h = direzione.x < 0.0

	_riproduci_animazione("Run")


func _gestisci_attacco() -> void:
	velocity = Vector2.ZERO
	move_and_slide()


# --- Danno e morte ---

func subisci_danno(danno: int) -> void:
	salute -= danno
	if salute <= 0:
		muori()


func muori() -> void:
	queue_free()


func infliggi_danno() -> void:
	# Il danno ora viene gestito dal sistema HitBox/HurtBox.
	# Questo metodo resta come hook per le classi figlie (es. effetti, suoni).
	pass


# --- Utilità ---

func _cerca_bersaglio() -> void:
	if not bersaglio:
		bersaglio = get_tree().get_first_node_in_group("Player") as Player


func _distanza_dal_bersaglio() -> float:
	if not bersaglio:
		return INF
	return global_position.distance_to(bersaglio.global_position)


func _aggiorna_timer(delta: float) -> void:
	if _timer_attacco > 0.0:
		_timer_attacco -= delta


func _cambia_stato(nuovo_stato: Stato) -> void:
	stato_corrente = nuovo_stato

	match nuovo_stato:
		Stato.IDLE:
			_riproduci_animazione("Idle")
		Stato.INSEGUIMENTO:
			_riproduci_animazione("Run")
		Stato.ATTACCO:
			_timer_attacco = ritardo_attacco
			_riproduci_animazione("Attack1")


func _riproduci_animazione(nome: String) -> void:
	if animatore and animatore.current_animation != nome:
		animatore.play(nome)


func _su_animazione_finita(nome_animazione: StringName) -> void:
	if nome_animazione == &"Attack1":
		infliggi_danno()
		if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
			_cambia_stato(Stato.INSEGUIMENTO)
		else:
			_cambia_stato(Stato.IDLE)
