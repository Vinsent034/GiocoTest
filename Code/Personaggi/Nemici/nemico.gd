extends CharacterBody2D
class_name Nemico

# --- ID nemico ---
@export var IDnemico: int = 0

# --- Risorsa nemico ---
@export var risorsa_nemico: NemicoResource

# --- Variabili base (sovrascrivibili dalle classi figlie) ---
@export var velocita: float = 80.0
@export var potenza_attacco: int = 5
@export var salute_massima: int = 50
@export var raggio_inseguimento: float = 200.0
@export var raggio_attacco: float = 30.0
@export var ritardo_attacco: float = 1.0
@export var raggio_separazione: float = 30.0
@export var forza_separazione: float = 60.0

# --- Drop alla morte ---
@export var drop_oro: PackedScene
@export var drop_bistecca: PackedScene
@export_range(0.0, 100.0, 1.0) var probabilita_bistecca: float = 20.0  # % di drop
@export var exp_valore: int = 10

signal morto

var salute: int
var _timer_attacco: float = 0.0

# --- Riferimenti ---
@export var animatore: AnimationPlayer
@export var sprite: Sprite2D
@export var hit_box: HitBox
@export var hurt_box: HurtBox
@export var hurt_box_collision: CollisionShape2D
@export var hit_box_collision: CollisionShape2D
@export var marker_danno: Marker2D
@export var sprite_comparsa: AnimatedSprite2D
var bersaglio: Player = null

# --- Macchina a stati ---
enum Stato { IDLE, INSEGUIMENTO, ATTACCO }
var stato_corrente: Stato = Stato.IDLE
var _in_comparsa: bool = false
var _in_morte: bool = false
var _drop_rilasciato: bool = false


func _ready() -> void:
	add_to_group("Nemici")
	collision_mask = 1

	if risorsa_nemico:
		velocita = risorsa_nemico.velocita
		potenza_attacco = risorsa_nemico.attacco
		salute_massima = risorsa_nemico.salute_massima
		raggio_inseguimento = risorsa_nemico.raggio_inseguimento
		raggio_attacco = risorsa_nemico.raggio_attacco
		ritardo_attacco = risorsa_nemico.ritardo_attacco
		_applica_modificatori_ruolo()

	salute = salute_massima
	if hit_box:
		hit_box.danno = potenza_attacco
		_disabilita_hitbox()
	if animatore:
		animatore.animation_finished.connect(_su_animazione_finita)
	if sprite_comparsa:
		sprite_comparsa.animation_finished.connect(_su_comparsa_finita)
		_in_comparsa = true
		sprite_comparsa.visible = true
		sprite_comparsa.play("Compari")


func _physics_process(delta: float) -> void:
	if _in_comparsa:
		return
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

	var direzione := global_position.direction_to(bersaglio.global_position)
	velocity = direzione * velocita + _calcola_forza_separazione()
	move_and_slide()

	if sprite and direzione.x != 0.0:
		sprite.flip_h = direzione.x < 0.0

	_riproduci_animazione("Run")


func _gestisci_attacco() -> void:
	velocity = Vector2.ZERO
	move_and_slide()


# --- Danno e morte ---

func subisci_danno(danno: int, is_critico: bool = false) -> void:
	salute -= danno
	if marker_danno:
		MostraValore.crea(marker_danno, danno, "DannoCritico" if is_critico else "Danno")
	if salute <= 0:
		muori()


func muori() -> void:
	if _in_morte:
		return
	_in_morte = true
	call_deferred("_spawna_drop")
	if hurt_box_collision:
		hurt_box_collision.set_deferred("disabled", true)
	if hit_box_collision:
		hit_box_collision.set_deferred("disabled", true)
	if sprite_comparsa:
		_in_comparsa = false
		set_physics_process(false)
		_disabilita_hitbox()
		velocity = Vector2.ZERO
		if sprite:
			sprite.visible = false
		if animatore:
			animatore.stop()
		sprite_comparsa.visible = true
		sprite_comparsa.play("Compari")
	else:
		call_deferred("_distruggi")


func _distruggi() -> void:
	remove_from_group("Nemici")
	_raccogli_exp()
	emit_signal("morto")
	Global.rilascio_id.emit(IDnemico)
	queue_free()


func _raccogli_exp() -> void:
	if exp_valore <= 0:
		return
	ManagerRaccolata.raccogli(1, exp_valore)
	if marker_danno:
		MostraValore.crea(marker_danno, exp_valore, "ExpRaccolta")


func _spawna_drop() -> void:
	if _drop_rilasciato:
		return
	_drop_rilasciato = true
	var parent = get_parent()
	if not parent:
		return
	var bistecca_effettiva: PackedScene = null
	if drop_bistecca and randf() * 100.0 < probabilita_bistecca:
		bistecca_effettiva = drop_bistecca
	var offsets := [Vector2(-12, -8), Vector2(0, 10)]
	var i := 0
	for scena in [drop_oro, bistecca_effettiva]:
		if scena:
			var oggetto = scena.instantiate()
			parent.add_child(oggetto)
			oggetto.global_position = global_position + offsets[i]
		i += 1


# --- Utilità ---

func _cerca_bersaglio() -> void:
	if not bersaglio:
		bersaglio = get_tree().get_first_node_in_group("Player") as Player


func _distanza_dal_bersaglio() -> float:
	if not bersaglio:
		return INF
	return global_position.distance_to(bersaglio.global_position)


func _calcola_forza_separazione() -> Vector2:
	var forza := Vector2.ZERO
	for nemico in get_tree().get_nodes_in_group("Nemici"):
		if nemico == self:
			continue
		var dist := global_position.distance_to(nemico.global_position)
		if dist < raggio_separazione and dist > 0.0:
			var via := global_position.direction_to(nemico.global_position)
			forza -= via * (raggio_separazione - dist) / raggio_separazione
	return forza * forza_separazione


func _aggiorna_timer(delta: float) -> void:
	if _timer_attacco > 0.0:
		_timer_attacco -= delta


func _cambia_stato(nuovo_stato: Stato) -> void:
	stato_corrente = nuovo_stato

	match nuovo_stato:
		Stato.IDLE:
			_disabilita_hitbox()
			_riproduci_animazione("Idle")
		Stato.INSEGUIMENTO:
			_disabilita_hitbox()
			_riproduci_animazione("Run")
		Stato.ATTACCO:
			_timer_attacco = ritardo_attacco
			_abilita_hitbox()
			_riproduci_animazione("Attack1")


func _riproduci_animazione(nome: String) -> void:
	if animatore and animatore.current_animation != nome:
		animatore.play(nome)


func _abilita_hitbox() -> void:
	if hit_box:
		hit_box.set_deferred("monitoring", true)
		hit_box.set_deferred("monitorable", true)


func _disabilita_hitbox() -> void:
	if hit_box:
		hit_box.set_deferred("monitoring", false)
		hit_box.set_deferred("monitorable", false)


# --- Modificatori ruolo ---

func _applica_modificatori_ruolo() -> void:
	if not risorsa_nemico:
		return

	match risorsa_nemico.tipo_ruolo:
		NemicoResource.TipoRuolo.TANK:
			_applica_modificatore_tank()
		NemicoResource.TipoRuolo.EVASIVO:
			_applica_modificatore_evasivo()
		NemicoResource.TipoRuolo.ASSASSINO:
			_applica_modificatore_assassino()
		NemicoResource.TipoRuolo.NORMALE:
			pass


func _applica_modificatore_tank() -> void:
	if sprite:
		sprite.scale *= 1.25


func _applica_modificatore_evasivo() -> void:
	velocita *= 1.25


func _applica_modificatore_assassino() -> void:
	potenza_attacco = int(potenza_attacco * 1.25)


func _su_animazione_finita(nome_animazione: StringName) -> void:
	if nome_animazione == &"Attack1":
		_disabilita_hitbox()
		if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
			_cambia_stato(Stato.INSEGUIMENTO)
		else:
			_cambia_stato(Stato.IDLE)


func _su_comparsa_finita() -> void:
	if _in_comparsa:
		_in_comparsa = false
		sprite_comparsa.visible = false
		if sprite:
			sprite.visible = true
	else:
		# Fine animazione di scomparsa: distruggi
		sprite_comparsa.visible = false
		_distruggi()
