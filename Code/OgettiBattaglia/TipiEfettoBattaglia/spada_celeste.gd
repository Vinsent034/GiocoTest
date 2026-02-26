extends Node2D
class_name SpadaCeleste

@export var player: Player
@export var intervallo_attacco: float = 1.5
@export var danno: int = 10

@onready var animatore: AnimationPlayer = $AnimationPlayer
@onready var hit_box: HitBox = $Corpo/HitBox

var _timer: float = 0.0
var _in_attacco: bool = false


func _ready() -> void:
	hit_box.danno = danno
	_disabilita_hitbox()
	visible = false
	hit_box.colpito.connect(_su_colpito)
	animatore.animation_finished.connect(_su_animazione_finita)


func _process(delta: float) -> void:
	if _in_attacco:
		return
	_timer -= delta
	if _timer <= 0.0:
		_avvia_attacco()


func _avvia_attacco() -> void:
	if not player:
		return
	_in_attacco = true
	visible = true
	_abilita_hitbox()
	var va_a_sinistra := player.velocity.x < 0.0
	if va_a_sinistra:
		animatore.play("ColpoSx")
	else:
		animatore.play("ColpoDx")


func _su_animazione_finita(_nome: StringName) -> void:
	visible = false
	_disabilita_hitbox()
	_in_attacco = false
	_timer = intervallo_attacco


func _su_colpito(hurt_box: Area2D) -> void:
	var parent = hurt_box.get_parent()
	if parent.has_method("subisci_danno"):
		parent.subisci_danno(danno)


func _abilita_hitbox() -> void:
	hit_box.set_deferred("monitoring", true)
	hit_box.set_deferred("monitorable", true)


func _disabilita_hitbox() -> void:
	hit_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)