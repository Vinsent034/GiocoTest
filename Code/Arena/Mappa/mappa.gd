extends Node
class_name Mappa


@export var Max_nemici_Spaun : int = 8
@export var Max_nemici_per_dentro_arena : int = 5
@export var marker_entrata: Marker2D
@export var blocco: StaticBody2D




@export var Nemico1: CartaNemico
@export var Nemico2: CartaNemico
@export var Nemico3: CartaNemico
@export var Nemico4: CartaNemico
@export var Nemico5: CartaNemico
@export var Nemico6: CartaNemico
@export var Nemico7: CartaNemico
@export var Nemico8: CartaNemico


func get_carte_nemici() -> Array[CartaNemico]:
	var risultato: Array[CartaNemico] = []
	for carta in [Nemico1, Nemico2, Nemico3, Nemico4, Nemico5, Nemico6, Nemico7, Nemico8]:
		if carta != null:
			risultato.append(carta)
	return risultato


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