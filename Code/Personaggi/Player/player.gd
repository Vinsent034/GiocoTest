extends CharacterBody2D
class_name Player

# --- variabili base ------------------------------------------------------
@export var velocita: float = 200.0            # velocità di movimento (pixel/sec)
@export var potenza_attacco: int = 10          # danno per colpo
@export var salute_massima: int = 100          # salute massima
var salute: int = salute_massima               # salute corrente
@export var ritardo_attacco: float = 0.5       # secondi tra un attacco e l'altro
var _timer_attacco: float = 0.0                # timer interno per il cooldown

func subisci_danno(danno: int) -> void:
    salute -= danno
    if salute <= 0:
        muori()


func muori() -> void:
    queue_free()