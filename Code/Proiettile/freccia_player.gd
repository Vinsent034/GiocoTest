extends Freccia
class_name FrecciaPlayer

@onready var _hit_box: HitBox = $HitBox


func _ready() -> void:
	super._ready()
	if Global.player:
		_hit_box.danno = Global.player.potenza_attacco
