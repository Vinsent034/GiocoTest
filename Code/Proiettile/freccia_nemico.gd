extends Node2D
class_name FrecciaNemico

enum Stato { LIBERA, IN_VOLO, RITORNO }

@export var risorsa: FrecciaResource

@export var velocita: float = 250.0
@export var gittata: float = 500.0
@export var lunghezza_scia: int = 12
@export var colore_scia: Color = Color(1.0, 0.85, 0.3, 0.8)

var stato: Stato = Stato.LIBERA
var _danno: int = 0
var _direzione: Vector2 = Vector2.ZERO
var _distanza_percorsa: float = 0.0
var _scia: Line2D

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _hit_box: HitBox = $HitBox
@onready var _collision: CollisionShape2D = $HitBox/CollisionShape2D


func _ready() -> void:
	if risorsa:
		_applica_risorsa()
	_crea_scia()
	_imposta_visibile(false)
	_hit_box.colpito.connect(_su_colpito)


func _applica_risorsa() -> void:
	velocita = risorsa.velocita
	gittata = risorsa.gittata
	lunghezza_scia = risorsa.lunghezza_scia
	colore_scia = risorsa.colore_scia
	if risorsa.sprite and _sprite:
		_sprite.texture = risorsa.sprite


func _crea_scia() -> void:
	_scia = Line2D.new()
	_scia.top_level = true
	_scia.width = 3.0
	_scia.default_color = colore_scia
	_scia.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_scia.end_cap_mode = Line2D.LINE_CAP_ROUND
	var gradient := Gradient.new()
	gradient.set_color(0, Color(colore_scia.r, colore_scia.g, colore_scia.b, 0.0))
	gradient.set_color(1, colore_scia)
	_scia.gradient = gradient
	add_child(_scia)


func spara(direzione: Vector2, danno: int) -> void:
	if stato != Stato.LIBERA:
		return
	_danno = danno
	_direzione = direzione
	_distanza_percorsa = 0.0
	_hit_box.danno = danno
	stato = Stato.IN_VOLO
	rotation = direzione.angle()
	_scia.visible = true
	_imposta_visibile(true)


func _physics_process(delta: float) -> void:
	match stato:
		Stato.IN_VOLO:
			_aggiorna_volo(delta)
		Stato.RITORNO:
			_aggiorna_ritorno(delta)


func _aggiorna_volo(delta: float) -> void:
	var spostamento := velocita * delta
	global_position += _direzione * spostamento
	_distanza_percorsa += spostamento
	_scia.add_point(global_position)
	if _scia.get_point_count() > lunghezza_scia:
		_scia.remove_point(0)
	if _distanza_percorsa >= gittata:
		_inizia_ritorno()


func _aggiorna_ritorno(delta: float) -> void:
	var destinazione: Vector2 = get_parent().global_position
	var verso := global_position.direction_to(destinazione)
	var spostamento := velocita * delta
	if global_position.distance_to(destinazione) <= spostamento:
		_torna_libera()
	else:
		global_position += verso * spostamento


func _su_colpito(hurt_box: Area2D) -> void:
	if stato != Stato.IN_VOLO:
		return
	if hurt_box.get_parent().has_method("subisci_danno"):
		hurt_box.get_parent().subisci_danno(_danno)
	_inizia_ritorno()


func _inizia_ritorno() -> void:
	stato = Stato.RITORNO
	_imposta_visibile(false)
	_scia.clear_points()
	_scia.visible = false
	_collision.set_deferred("disabled", true)


func _torna_libera() -> void:
	stato = Stato.LIBERA
	position = Vector2.ZERO
	rotation = 0.0
	_scia.clear_points()
	_collision.set_deferred("disabled", false)


func _imposta_visibile(visibile: bool) -> void:
	_sprite.visible = visibile
	_hit_box.set_deferred("monitoring", visibile)
	_hit_box.set_deferred("monitorable", visibile)
