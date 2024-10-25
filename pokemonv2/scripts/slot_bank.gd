extends Control

@export_category("Objetos")
@export var background: TextureRect
@export var sprite: TextureRect = null
@export var on_companion: TextureRect

@export_category("Variaveis")
@export var id: int
@export var name_pokemon: String
@export var dex_number: String
@export var ability: String
@export var shiny: bool = false
@export var background_list: Array


func _ready() -> void:
	background.texture = load(background_list.pick_random())


func update_on_companion(id_pokemon: int, function: String) -> void:
	match function:
		"add":
			if id_pokemon == id:
				on_companion.show()
			
		"remove":
			if id_pokemon == id:
				on_companion.hide()
