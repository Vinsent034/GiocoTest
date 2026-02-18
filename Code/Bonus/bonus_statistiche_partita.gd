extends Node2D
class_name BonusStatistichePartita

@export var punti_abilitati: int = 20

@export var vita: int = 0
@export var attacco: int = 0
@export var difesa: int = 0
@export var critico: int = 0
@export var elusione: int = 0
@export var velocita: int = 0
@export var fortuna: int = 0

# Riferimenti alle label (colonna "Nome Bonus" che mostra nome + valore)
@onready var label_bonus: Label = $TileMapLayer/Label
@onready var label_vita: Label = $TileMapLayer/"Nome Bonus"/Sprite2D
@onready var label_attacco: Label = $TileMapLayer/"Nome Bonus"/Tool03
@onready var label_difesa: Label = $TileMapLayer/"Nome Bonus"/Tool04
@onready var label_critico: Label = $TileMapLayer/"Nome Bonus"/Cuore
@onready var label_elusione: Label = $TileMapLayer/"Nome Bonus"/Elusione
@onready var label_velocita: Label = $TileMapLayer/"Nome Bonus"/Velocità
@onready var label_fortuna: Label = $TileMapLayer/"Nome Bonus"/Fortuna

# Bottoni aumenta
@onready var btn_aumenta_vita: Button = $TileMapLayer/"Tasto Aumenta"/Sprite2D
@onready var btn_aumenta_attacco: Button = $TileMapLayer/"Tasto Aumenta"/Tool03
@onready var btn_aumenta_difesa: Button = $TileMapLayer/"Tasto Aumenta"/Tool04
@onready var btn_aumenta_critico: Button = $TileMapLayer/"Tasto Aumenta"/Cuore
@onready var btn_aumenta_elusione: Button = $TileMapLayer/"Tasto Aumenta"/Elusione
# Nella scena i bottoni sono in ordine: ...Elusione, Fortuna, Velocità
# Le label sono in ordine: ...Elusione, Velocità, Fortuna
# Quindi il bottone "Fortuna" è sulla riga visiva di Velocità e viceversa
@onready var btn_aumenta_velocita: Button = $TileMapLayer/"Tasto Aumenta"/Fortuna
@onready var btn_aumenta_fortuna: Button = $TileMapLayer/"Tasto Aumenta"/Velocità

# Bottoni decrementa
@onready var btn_decrementa_vita: Button = $TileMapLayer/"Tasto Decrementa"/Sprite2D
@onready var btn_decrementa_attacco: Button = $TileMapLayer/"Tasto Decrementa"/Tool03
@onready var btn_decrementa_difesa: Button = $TileMapLayer/"Tasto Decrementa"/Tool04
@onready var btn_decrementa_critico: Button = $TileMapLayer/"Tasto Decrementa"/Cuore
@onready var btn_decrementa_elusione: Button = $TileMapLayer/"Tasto Decrementa"/Elusione
@onready var btn_decrementa_velocita: Button = $TileMapLayer/"Tasto Decrementa"/Fortuna
@onready var btn_decrementa_fortuna: Button = $TileMapLayer/"Tasto Decrementa"/Velocità

var _punti_rimanenti: int = 0

# Valori minimi dopo ogni Conferma (non si può decrementare sotto questi)
var _min_vita: int = 0
var _min_attacco: int = 0
var _min_difesa: int = 0
var _min_critico: int = 0
var _min_elusione: int = 0
var _min_velocita: int = 0
var _min_fortuna: int = 0

@onready var btn_resetta: TextureButton = $Resetta
@onready var btn_conferma: TextureButton = $Conferma

func _ready() -> void:
	_punti_rimanenti = punti_abilitati
	_aggiorna_ui()
	_collega_segnali()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug"):
		visible = true

func _collega_segnali() -> void:
	btn_resetta.pressed.connect(resetta)
	btn_conferma.pressed.connect(_on_conferma)
	ManagerRaccolata.livello_su.connect(_on_livello_su)
	btn_aumenta_vita.pressed.connect(_on_aumenta.bind("vita"))
	btn_aumenta_attacco.pressed.connect(_on_aumenta.bind("attacco"))
	btn_aumenta_difesa.pressed.connect(_on_aumenta.bind("difesa"))
	btn_aumenta_critico.pressed.connect(_on_aumenta.bind("critico"))
	btn_aumenta_elusione.pressed.connect(_on_aumenta.bind("elusione"))
	btn_aumenta_velocita.pressed.connect(_on_aumenta.bind("velocita"))
	btn_aumenta_fortuna.pressed.connect(_on_aumenta.bind("fortuna"))

	btn_decrementa_vita.pressed.connect(_on_decrementa.bind("vita"))
	btn_decrementa_attacco.pressed.connect(_on_decrementa.bind("attacco"))
	btn_decrementa_difesa.pressed.connect(_on_decrementa.bind("difesa"))
	btn_decrementa_critico.pressed.connect(_on_decrementa.bind("critico"))
	btn_decrementa_elusione.pressed.connect(_on_decrementa.bind("elusione"))
	btn_decrementa_velocita.pressed.connect(_on_decrementa.bind("velocita"))
	btn_decrementa_fortuna.pressed.connect(_on_decrementa.bind("fortuna"))

func _on_aumenta(stat: String) -> void:
	if _punti_rimanenti <= 0:
		return
	_punti_rimanenti -= 1
	match stat:
		"vita":      vita += 1
		"attacco":   attacco += 1
		"difesa":    difesa += 1
		"critico":   critico += 1
		"elusione":  elusione += 1
		"velocita":  velocita += 1
		"fortuna":   fortuna += 1
	_aggiorna_ui()

func _on_conferma() -> void:
	var sp: StatPlayer = Global.stat_player
	if sp:
		sp.aumenta_vita_massima(vita - _min_vita)
		sp.aumenta_attacco(attacco - _min_attacco)
		sp.aumenta_difesa(difesa - _min_difesa)
		sp.aumenta_critico(critico - _min_critico)
		sp.aumenta_schivata(elusione - _min_elusione)
		sp.aumenta_velocita(velocita - _min_velocita)
		sp.aumenta_fortuna(fortuna - _min_fortuna)
	_min_vita = vita
	_min_attacco = attacco
	_min_difesa = difesa
	_min_critico = critico
	_min_elusione = elusione
	_min_velocita = velocita
	_min_fortuna = fortuna
	visible = false

func _on_decrementa(stat: String) -> void:
	match stat:
		"vita":
			if vita <= _min_vita: return
			vita -= 1
		"attacco":
			if attacco <= _min_attacco: return
			attacco -= 1
		"difesa":
			if difesa <= _min_difesa: return
			difesa -= 1
		"critico":
			if critico <= _min_critico: return
			critico -= 1
		"elusione":
			if elusione <= _min_elusione: return
			elusione -= 1
		"velocita":
			if velocita <= _min_velocita: return
			velocita -= 1
		"fortuna":
			if fortuna <= _min_fortuna: return
			fortuna -= 1
	_punti_rimanenti += 1
	_aggiorna_ui()

func _aggiorna_ui() -> void:
	if label_bonus:
		label_bonus.text = "Bonus : " + str(_punti_rimanenti)
	if label_vita:
		label_vita.text = "Max Hp : " + str(vita)
	if label_attacco:
		label_attacco.text = "Attack : " + str(attacco)
	if label_difesa:
		label_difesa.text = "Difesa : " + str(difesa)
	if label_critico:
		label_critico.text = "Critico : " + str(critico)
	if label_elusione:
		label_elusione.text = "Elusione: " + str(elusione)
	if label_velocita:
		label_velocita.text = "Velocità: " + str(velocita)
	if label_fortuna:
		label_fortuna.text = "Fortuna: " + str(fortuna)

func _on_livello_su(token: int) -> void:
	_punti_rimanenti += token
	_aggiorna_ui()

func resetta() -> void:
	var sp: StatPlayer = Global.stat_player
	if sp:
		sp.aumenta_vita_massima(-_min_vita)
		sp.aumenta_attacco(-_min_attacco)
		sp.aumenta_difesa(-_min_difesa)
		sp.aumenta_critico(-_min_critico)
		sp.aumenta_schivata(-_min_elusione)
		sp.aumenta_velocita(-_min_velocita)
		sp.aumenta_fortuna(-_min_fortuna)
	vita = 0
	attacco = 0
	difesa = 0
	critico = 0
	elusione = 0
	velocita = 0
	fortuna = 0
	_min_vita = 0
	_min_attacco = 0
	_min_difesa = 0
	_min_critico = 0
	_min_elusione = 0
	_min_velocita = 0
	_min_fortuna = 0
	_punti_rimanenti = punti_abilitati
	_aggiorna_ui()
