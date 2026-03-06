extends CharacterBody2D
class_name PlayerHome

@export var IdPlayer : int = 0
@export var AnimazionePlayerHome: Array[AnimationPlayer]
@export var AnimazioneAsseganta : AnimationPlayer
@export var velocita : float = 100.0
@export var Sprite : Node2D

enum Stato { IDLE, RUN }
var stato_corrente : Stato = Stato.IDLE
var ultima_direzione_x : float = 1.0


func _ready() -> void:
	if IdPlayer < AnimazionePlayerHome.size():
		AnimazioneAsseganta = AnimazionePlayerHome[IdPlayer]
	_entra_stato(Stato.IDLE)


func _physics_process(_delta: float) -> void:
	var direzione := Vector2(
		Input.get_axis("Sinistra", "Destra"),
		Input.get_axis("Su", "Giu")
	).normalized()

	velocity = direzione * velocita
	move_and_slide()

	if direzione.x != 0.0:
		ultima_direzione_x = direzione.x

	if Sprite != null:
		Sprite.scale.x = -1.0 if ultima_direzione_x < 0.0 else 1.0

	match stato_corrente:
		Stato.IDLE:
			if velocity != Vector2.ZERO:
				_cambia_stato(Stato.RUN)
		Stato.RUN:
			if velocity == Vector2.ZERO:
				_cambia_stato(Stato.IDLE)


func _cambia_stato(nuovo_stato: Stato) -> void:
	if stato_corrente == nuovo_stato:
		return
	stato_corrente = nuovo_stato
	_entra_stato(nuovo_stato)


func _entra_stato(stato: Stato) -> void:
	if AnimazioneAsseganta == null:
		return
	match stato:
		Stato.IDLE:
			AnimazioneAsseganta.play("Idle")
		Stato.RUN:
			AnimazioneAsseganta.play("Run")
