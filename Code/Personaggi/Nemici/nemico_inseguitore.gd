extends Nemico
class_name NemicoInseguitore

func _ready() -> void:
	super._ready()
	# L'inseguitore fa danno da contatto: HitBox sempre attiva
	if hit_box:
		_abilita_hitbox()


func _gestisci_inseguimento() -> void:
	if not bersaglio:
		_cambia_stato(Stato.IDLE)
		return

	var distanza := _distanza_dal_bersaglio()

	if distanza > raggio_inseguimento:
		_cambia_stato(Stato.IDLE)
		return

	if distanza < 5.0:
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


func _cambia_stato(nuovo_stato: Stato) -> void:
	stato_corrente = nuovo_stato

	match nuovo_stato:
		Stato.IDLE:
			_disabilita_hitbox()
			_riproduci_animazione("Idle")
		Stato.INSEGUIMENTO:
			# L'inseguitore NON disabilita hitbox durante inseguimento
			_abilita_hitbox()
			_riproduci_animazione("Run")
		Stato.ATTACCO:
			_timer_attacco = ritardo_attacco
			_abilita_hitbox()
			_riproduci_animazione("Attack1")
