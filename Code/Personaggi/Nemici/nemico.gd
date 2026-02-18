extends CharacterBody2D
class_name Nemico

# --- Variabili base (sovrascrivibili dalle classi figlie) ---
@export var velocita: float = 80.0
@export var potenza_attacco: int = 5
@export var salute_massima: int = 50
@export var raggio_inseguimento: float = 200.0
@export var raggio_attacco: float = 30.0
@export var ritardo_attacco: float = 1.0

# --- Drop alla morte ---
@export var drop_oro: PackedScene
@export var drop_exp: PackedScene
@export var drop_bistecca: PackedScene
@export_range(0.0, 100.0, 1.0) var probabilita_bistecca: float = 20.0  # % di drop

var salute: int
var _timer_attacco: float = 0.0

# --- Riferimenti ---
@export var animatore: AnimationPlayer
@export var sprite: Sprite2D
@export var hit_box: HitBox
@export var marker_danno: Marker2D
var bersaglio: Player = null

# --- Macchina a stati ---
enum Stato { IDLE, INSEGUIMENTO, ATTACCO }
var stato_corrente: Stato = Stato.IDLE


func _ready() -> void:
	add_to_group("Nemici")
	salute = salute_massima
	if hit_box:
		_disabilita_hitbox()
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
	if marker_danno:
		MostraValore.crea(marker_danno, danno, "Danno")
	if salute <= 0:
		muori()


func muori() -> void:
	call_deferred("_spawna_drop")
	call_deferred("queue_free")


func _spawna_drop() -> void:
	var parent = get_parent()
	if not parent:
		return
	var bistecca_effettiva: PackedScene = null
	if drop_bistecca and randf() * 100.0 < probabilita_bistecca:
		bistecca_effettiva = drop_bistecca
	var offsets := [Vector2(-12, -8), Vector2(12, -8), Vector2(0, 10)]
	var i := 0
	for scena in [drop_oro, drop_exp, bistecca_effettiva]:
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
		hit_box.monitoring = true
		hit_box.monitorable = true


func _disabilita_hitbox() -> void:
	if hit_box:
		hit_box.monitoring = false
		hit_box.monitorable = false


func _su_animazione_finita(nome_animazione: StringName) -> void:
	if nome_animazione == &"Attack1":
		_disabilita_hitbox()
		if bersaglio and _distanza_dal_bersaglio() <= raggio_inseguimento:
			_cambia_stato(Stato.INSEGUIMENTO)
		else:
			_cambia_stato(Stato.IDLE)
