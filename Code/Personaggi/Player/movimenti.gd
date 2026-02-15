extends Node

# --- Riferimenti ai nodi ---
@onready var giocatore: Player = get_parent() as Player
@export var animatore: AnimationPlayer
@export var sprite: Sprite2D

# --- Stati possibili ---
enum Stato { IDLE, CORSA, ATTACCO, GUARDIA }
var stato_corrente: Stato = Stato.IDLE


func _ready() -> void:
	# Quando l'attacco finisce, torna allo stato appropriato
	animatore.animation_finished.connect(_su_animazione_finita)


func _physics_process(_delta: float) -> void:
	match stato_corrente:
		Stato.IDLE:
			_gestisci_stato_idle()
		Stato.CORSA:
			_gestisci_stato_corsa()
		Stato.ATTACCO:
			_gestisci_stato_attacco()
		Stato.GUARDIA:
			_gestisci_stato_guardia()


# --- Gestione singoli stati ---

func _gestisci_stato_idle() -> void:
	giocatore.velocity = Vector2.ZERO
	giocatore.move_and_slide()

	if Input.is_action_just_pressed("Click"):
		_cambia_stato(Stato.ATTACCO)
	elif Input.is_action_pressed("Click2"):
		_cambia_stato(Stato.GUARDIA)
	elif _ottieni_direzione_input() != Vector2.ZERO:
		_cambia_stato(Stato.CORSA)


func _gestisci_stato_corsa() -> void:
	var direzione := _ottieni_direzione_input()

	if Input.is_action_just_pressed("Click"):
		_cambia_stato(Stato.ATTACCO)
		return
	if Input.is_action_pressed("Click2"):
		_cambia_stato(Stato.GUARDIA)
		return

	if direzione == Vector2.ZERO:
		_cambia_stato(Stato.IDLE)
		return

	# Gira lo sprite in base alla direzione orizzontale
	if direzione.x != 0.0:
		sprite.flip_h = direzione.x < 0.0

	giocatore.velocity = direzione * giocatore.velocita
	giocatore.move_and_slide()


func _gestisci_stato_attacco() -> void:
	# Fermo durante l'attacco
	giocatore.velocity = Vector2.ZERO
	giocatore.move_and_slide()


func _gestisci_stato_guardia() -> void:
	# Fermo durante la guardia
	giocatore.velocity = Vector2.ZERO
	giocatore.move_and_slide()

	if not Input.is_action_pressed("Click2"):
		_cambia_stato(Stato.IDLE)


# --- Cambio di stato ---

func _cambia_stato(nuovo_stato: Stato) -> void:
	stato_corrente = nuovo_stato

	match nuovo_stato:
		Stato.IDLE:
			animatore.play("Idle")
		Stato.CORSA:
			animatore.play("Run")
		Stato.ATTACCO:
			animatore.play("Attack1")
		Stato.GUARDIA:
			animatore.play("Guard")


# --- Callback animazione finita ---

func _su_animazione_finita(nome_animazione: StringName) -> void:
	if nome_animazione == &"Attack1":
		# Dopo l'attacco torna a idle o corsa
		if _ottieni_direzione_input() != Vector2.ZERO:
			_cambia_stato(Stato.CORSA)
		else:
			_cambia_stato(Stato.IDLE)


# --- Input direzione ---

func _ottieni_direzione_input() -> Vector2:
	var direzione := Vector2.ZERO
	direzione.x = Input.get_axis("Sinistra", "Destra")
	direzione.y = Input.get_axis("Su", "Giu")

	if direzione.length() > 0.0:
		direzione = direzione.normalized()

	return direzione
