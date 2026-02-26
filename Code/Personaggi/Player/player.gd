extends CharacterBody2D
class_name Player

# --- variabili base ------------------------------------------------------
@export var velocita: float = 200.0            # velocità di movimento (pixel/sec)
@export var potenza_attacco: int = 10          # danno per colpo
@export var salute_massima: int = 100          # salute massima
@export var attacco: int = 0                   # bonus attacco
@export var difesa: int = 0                    # riduzione danno
@export var schivata: int = 0                  # probabilità di schivare (%)
@export var critico: int = 0                   # probabilità di colpo critico (%)
@export var fortuna: int = 0                   # bonus fortuna
var salute: int = salute_massima               # salute corrente
var _tween_barra: Tween
@onready var sprite: Sprite2D = $Sprite2D
@onready var barra_vita: ProgressBar = $BarraVita
@onready var label_pv: Label = $BarraVita/LabelPV
@onready var marker_danno: Marker2D = $BarraVita/Marker2D
@onready var hurt_box: Area2D = $HurtBox
@onready var hurt_box_shape: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var timer_invincibilita: Timer = $TimerInvincibilita
@onready var animazioni: AnimatedSprite2D = $Animazioni

func _ready() -> void:
	Global.player = self
	if sprite and not sprite.material:
		var shader = load("res://Code/Personaggi/Player/flash_bianco.gdshader")
		var mat = ShaderMaterial.new()
		mat.shader = shader
		sprite.material = mat
	barra_vita.max_value = salute_massima
	barra_vita.value = salute
	label_pv.text = "%d" % salute
	timer_invincibilita.timeout.connect(_on_timer_invincibilita_timeout)
	ManagerRaccolata.bistecca_raccolta.connect(_on_bistecca_raccolta)

func subisci_danno(danno: int) -> void:
	if not timer_invincibilita.is_stopped():
		return
	# Schivata: genera un numero da 1 a 100, se <= schivata il danno viene evitato
	if schivata > 0 and randi_range(1, 100) <= schivata:
		_mostra_valore(0, "Schivata")
		return
	# Difesa: riduce il danno, minimo 0
	var danno_finale := maxi(danno - difesa, 0)
	salute -= danno_finale
	_aggiorna_barra_vita()
	_flash_bianco()
	_mostra_valore(danno_finale, "DannoPlayer")
	hurt_box.set_deferred("monitorable", false)
	hurt_box.set_deferred("monitoring", false)
	hurt_box_shape.set_deferred("disabled", true)
	timer_invincibilita.start()
	if salute <= 0:
		muori()


func _on_timer_invincibilita_timeout() -> void:
	hurt_box.monitoring = true
	hurt_box.monitorable = true
	hurt_box_shape.disabled = false


func _aggiorna_barra_vita() -> void:
	if _tween_barra and _tween_barra.is_valid():
		_tween_barra.kill()
	_tween_barra = create_tween()
	_tween_barra.tween_property(barra_vita, "value", float(salute), 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# Cambia colore in base alla percentuale di vita
	var percentuale := float(salute) / float(salute_massima)
	var colore: Color
	if percentuale > 0.5:
		colore = Color(0.3, 0.9, 0.3, 1)   # verde
	elif percentuale > 0.25:
		colore = Color(0.95, 0.8, 0.2, 1)   # giallo
	else:
		colore = Color(0.9, 0.2, 0.2, 1)    # rosso
	var stile_fill := barra_vita.get_theme_stylebox("fill") as StyleBoxFlat
	if stile_fill:
		stile_fill.bg_color = colore
	label_pv.text = "%d" % salute


func _mostra_valore(valore: int, tipo: String) -> void:
	MostraValore.crea(marker_danno, valore, tipo)


func _flash_bianco() -> void:
	if sprite and sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("flash_intensita", 1.0)
		await get_tree().create_timer(0.1).timeout
		sprite.material.set_shader_parameter("flash_intensita", 0.0)


func _on_bistecca_raccolta(valore: int) -> void:
	var cura := int(salute_massima * valore / 100.0)
	salute = mini(salute + cura, salute_massima)
	_aggiorna_barra_vita()
	animazioni.play("new_animation")


func muori() -> void:
	queue_free()
