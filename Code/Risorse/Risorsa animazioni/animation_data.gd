# Code/Resources/animation_data.gd
extends Resource
class_name AnimationData

## Nome della texture con gli sprite
@export var texture_idle: Texture2D
@export var texture_run: Texture2D
@export var texture_attack: Texture2D
@export var texture_guard: Texture2D

## Numero frame orizzontali per ogni animazione
@export var hframes_idle: int = 8
@export var hframes_run: int = 6
@export var hframes_attack: int = 4
@export var hframes_guard: int = 6

## Durata frame (secondi)
@export var frame_duration: float = 0.1

## Dati per ogni stato
var animations: Dictionary = {
	"Idle": {
		"texture": texture_idle,
		"hframes": hframes_idle,
		"loop": true,
	},
	"Run": {
		"texture": texture_run,
		"hframes": hframes_run,
		"loop": true,
	},
	"Attack1": {
		"texture": texture_attack,
		"hframes": hframes_attack,
		"loop": false,
	},
	"Guard": {
		"texture": texture_guard,
		"hframes": hframes_guard,
		"loop": true,
	}
}
