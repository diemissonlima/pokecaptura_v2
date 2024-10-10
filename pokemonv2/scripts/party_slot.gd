extends Control

@export_category("Obejtos")
@export var sprite: TextureRect = null
@export var background: TextureRect

@export_category("Variaveis")
@export var background_list: Array


func _ready() -> void:
	background.texture = load(background_list.pick_random())
