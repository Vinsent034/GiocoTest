extends Node2D
class_name Freccia

@export var risorsa: FrecciaResource

@export var velocita: float = 300.0
@export var gittata: float = 150.0
@export var lunghezza_scia: int = 12
@export var colore_scia: Color = Color(1.0, 0.85, 0.3, 0.8)

var direzione: Vector2 = Vector2.RIGHT
var _distanza_percorsa: float = 0.0
var _scia: Line2D

@onready var hit_box: HitBox = $HitBox
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if risorsa:
		_applica_risorsa()
	rotation = direzione.angle()
	hit_box.colpito.connect(_su_colpito)
	_crea_scia()


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


func _physics_process(delta: float) -> void:
	var spostamento := velocita * delta
	position += direzione * spostamento
	_distanza_percorsa += spostamento

	_scia.add_point(global_position)
	if _scia.get_point_count() > lunghezza_scia:
		_scia.remove_point(0)

	if _distanza_percorsa >= gittata:
		queue_free()


func _su_colpito(hurt_box: Area2D) -> void:
	var parent = hurt_box.get_parent()
	if parent.is_in_group("Nemici") or parent.is_in_group("Player"):
		queue_free()
