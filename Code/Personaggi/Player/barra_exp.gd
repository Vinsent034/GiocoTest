extends ProgressBar
class_name BarraExp
@export var exp_base_per_livello: int = 50
@export var fattore_crescita: float = 1.2

signal livello_su(token: int)

var livello: int = 1
var exp_per_livello: int
var exp_corrente: int = 0
var _tween_barra: Tween

@onready var label_livello: Label = $LabelLivello


func _ready() -> void:
	exp_per_livello = exp_base_per_livello
	max_value = exp_per_livello
	value = exp_corrente
	label_livello.text = "Lv %d" % livello
	ManagerRaccolata.exp_raccolta.connect(_on_exp_raccolta)


func _on_exp_raccolta(valore: int) -> void:
	exp_corrente += valore
	while exp_corrente >= exp_per_livello:
		exp_corrente -= exp_per_livello
		livello += 1
		exp_per_livello = int(exp_base_per_livello * pow(fattore_crescita, livello - 1))
		max_value = exp_per_livello
		label_livello.text = "Lv %d" % livello
		livello_su.emit(1)
		ManagerRaccolata.livello_su.emit(1)
	_aggiorna_barra()


func _aggiorna_barra() -> void:
	if _tween_barra and _tween_barra.is_valid():
		_tween_barra.kill()
	_tween_barra = create_tween()
	_tween_barra.tween_property(self, "value", float(exp_corrente), 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
