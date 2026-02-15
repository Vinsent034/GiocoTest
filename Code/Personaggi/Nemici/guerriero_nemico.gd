extends Nemico
class_name GuerrieroNemico

# Sovrascrive i valori base del Nemico
# (puoi anche cambiarli dall'inspector grazie a @export)

func _ready() -> void:
	velocita = 100.0
	potenza_attacco = 8
	salute_massima = 60
	raggio_inseguimento = 250.0
	raggio_attacco = 35.0
	ritardo_attacco = 0.8
	super._ready()
