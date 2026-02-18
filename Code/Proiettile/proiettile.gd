extends Node2D
class_name Freccia

@export var velocita: float = 300.0
@export var gittata: float = 150.0

var direzione: Vector2 = Vector2.RIGHT
var _distanza_percorsa: float = 0.0

@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	rotation = direzione.angle()
	hit_box.colpito.connect(_su_colpito)


func _physics_process(delta: float) -> void:
	var spostamento := velocita * delta
	position += direzione * spostamento
	_distanza_percorsa += spostamento
	if _distanza_percorsa >= gittata:
		queue_free()


func _su_colpito(_hurt_box: Area2D) -> void:
	queue_free()
