extends Node2D
class_name Esplosione

signal pronta

@export var danno: int = 15

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: HitBox = $HitBox


func _ready() -> void:
	hit_box.danno = danno
	sprite.animation_finished.connect(_su_animazione_finita)
	_disattiva()


func attiva(pos: Vector2) -> void:
	global_position = pos
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	_esplodi()


func _esplodi() -> void:
	sprite.visible = true
	sprite.sprite_frames.set_animation_loop("Explosion", false)
	sprite.play("Explosion")
	hit_box.set_deferred("monitoring", true)
	hit_box.set_deferred("monitorable", true)


func _su_animazione_finita() -> void:
	_disattiva()
	pronta.emit()


func _disattiva() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	sprite.stop()
	sprite.frame = 0
	hit_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
