extends Freccia
class_name FrecciaPlayer

@onready var _hit_box: HitBox = $HitBox

var critico: int = 0


func _ready() -> void:
	super._ready()
	if Global.player:
		var danno_base := Global.player.potenza_attacco
		var is_critico := critico > 0 and randi_range(1, 100) <= critico
		_hit_box.critico = is_critico
		_hit_box.danno = danno_base * 2 if is_critico else danno_base
