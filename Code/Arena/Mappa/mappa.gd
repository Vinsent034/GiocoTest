extends Node
class_name Mappa


@export var Max_nemici_Spaun : int = 8
@export var Max_nemici_per_dentro_arena : int = 5
@export var marker_entrata: Marker2D
@export var blocco: StaticBody2D




@export var carte_nemici: Array[CartaNemico] = []


func get_carte_nemici() -> Array[CartaNemico]:
	return carte_nemici.filter(func(c): return c != null)


func _ready():
	Global.RiferiemntoMappa = self
	Global.TuttiINemiciAbbattuti.connect(DisattivaBlocco)
	if marker_entrata:
		call_deferred("_posiziona_player")


func _posiziona_player() -> void:
	if Global.player and marker_entrata:
		Global.player.global_position = marker_entrata.global_position


func AvviaIlTween(_area: Area2D) -> void:
	Global.AvviaTween.emit()


func DisattivaBlocco() -> void:
	if blocco:
		blocco.collision_layer = 0
		blocco.collision_mask = 0