extends Control

@export_category("Obejtos")
@export var sprite: TextureRect = null
@export var background: TextureRect

@export_category("Variaveis")
@export var background_list: Array
@export var id_pokemon: int

var pokemon_info: Dictionary


func _ready() -> void:
	background.texture = load(background_list.pick_random())
