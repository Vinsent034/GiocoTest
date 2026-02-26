extends VBoxContainer
class_name NemiciDaSconfiggere

@export var texture_nemici: Array[Texture2D] = [null, null, null, null, null, null, null, null]
@export var icone_nemici: Array[TextureRect] = [null, null, null, null]
@export var LabelNumeroNemici: Array[Label] = [null, null, null, null]

@export var Max_nemci : int = 8


func _ready() -> void:
	genera_icone()


func _distribuisci_nemici() -> Array[int]:
	var distribuzione: Array[int] = [0, 0, 0, 0]
	var rimasti := Max_nemci
	for i in 4:
		if rimasti <= 0:
			break
		var max_questa_sezione := rimasti - (3 - i)
		if max_questa_sezione <= 0:
			continue
		var quantita := randi_range(0, max_questa_sezione)
		distribuzione[i] = quantita
		rimasti -= quantita
	return distribuzione


func genera_icone() -> void:
	var distribuzione := _distribuisci_nemici()
	for i in 4:
		if icone_nemici[i] != null:
			var indice_random := randi_range(0, 7)
			icone_nemici[i].texture = texture_nemici[indice_random]
		if LabelNumeroNemici[i] != null:
			LabelNumeroNemici[i].text = "0/" + str(distribuzione[i])
