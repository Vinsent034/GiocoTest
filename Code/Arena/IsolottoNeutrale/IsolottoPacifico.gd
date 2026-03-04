extends Node2D
class_name IsolottoPacifico

@export var Distanza_da_percorrere: int = 200
@export var velocità: int = 90
@export var marker_entrata: Marker2D

@onready var barca: Area2D = $Barca
@onready var blocco: StaticBody2D = $Barca/Blocco
@onready var blocco_collision: CollisionPolygon2D = $Barca/Blocco/CollisionPolygon2D

var _in_movimento: bool = false
var _distanza_percorsa: float = 0.0


func _ready() -> void:
	if marker_entrata:
		call_deferred("_posiziona_player")
	call_deferred("_salva")


func _posiziona_player() -> void:
	if Global.player and marker_entrata:
		Global.player.global_position = marker_entrata.global_position


func Parti(_area: Area2D) -> void:
	if _in_movimento:
		return
	blocco_collision.set_deferred("disabled", false)
	_in_movimento = true


func _physics_process(delta: float) -> void:
	if not _in_movimento:
		return

	var spostamento := velocità * delta
	barca.position.y -= spostamento
	_distanza_percorsa += spostamento

	if _distanza_percorsa >= Distanza_da_percorrere:
		_in_movimento = false
		set_physics_process(false)
		_avvia_tween()


func _salva() -> void:
	var gestore := Global.gestore_arena
	if gestore and gestore.caricato_da_file:
		gestore.caricato_da_file = false
		return
	SaveManager.salva(gestore)


func _avvia_tween() -> void:
	Global.AvviaTween.emit()

