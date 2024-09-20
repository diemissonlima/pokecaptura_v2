extends Control
class_name Slot

@export_category("Variaveis")
@export var slot_id: String
@export var img_path: String
@export var background_list: Array[String]

@export_category("Obejtos")
@export var sprite: TextureRect
@export var background: TextureRect
@export var id_poke: Label

var gen: String = "gen1"


func _ready() -> void:
	background.texture = load(background_list.pick_random())
	id_poke.text = slot_id
	sprite.texture = load("res://assets/pokemon_sprite/" + gen + "/normal/" + slot_id + ".png")
	sprite.modulate = 0
