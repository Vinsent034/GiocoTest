extends Area2D
class_name HurtBox

# Segnale emesso quando una HitBox entra nella HurtBox
signal ricevuto_colpo(hit_box: HitBox)


func _ready() -> void:
	area_entered.connect(_su_area_entrata)


func _su_area_entrata(area: Area2D) -> void:
	if area is HitBox:
		ricevuto_colpo.emit(area)
		# Applica il danno al nodo padre se ha il metodo subisci_danno
		var proprietario = get_parent()
		if proprietario.has_method("subisci_danno"):
			proprietario.subisci_danno(area.danno)
