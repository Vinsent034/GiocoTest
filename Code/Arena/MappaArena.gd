extends TileMapLayer
class_name Mappa

# --- Scene nemici dell'arena ---
@export var scena_nemico_1: PackedScene
@export var scena_nemico_2: PackedScene
@export var scena_nemico_3: PackedScene
@export var scena_nemico_4: PackedScene
@export var scena_nemico_5: PackedScene
@export var scena_nemico_6: PackedScene
@export var scena_nemico_7: PackedScene
@export var scena_nemico_8: PackedScene

# --- Segnale ---
signal arena_pronta(arena: Node)


func _ready() -> void:
	emit_signal("arena_pronta", self)
