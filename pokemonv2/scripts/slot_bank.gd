extends Control

@export_category("Objetos")
@export var background: TextureRect
@export var sprite: TextureRect = null

@export_category("Variaveis")
@export var id: int
@export var name_pokemon: String
@export var dex_number: String
@export var date_capture: String
@export var time_capture: String
@export var primary_type: String
@export var secondary_type: String
@export var region: String
@export var nature: String
@export var weight: float
@export var shiny: bool = false
@export var background_list: Array


func _ready() -> void:
	background.texture = load(background_list.pick_random())
