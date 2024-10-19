extends Control
class_name Slot

@export_category("Variaveis")
@export var slot_id: String
@export var background_list: Array[String]
@export var sprite_path: String

@export_category("Obejtos")
@export var sprite: TextureRect
@export var background: TextureRect
@export var id_poke: Label

var gen: String = ""


func _ready() -> void:
	background.texture = load(background_list.pick_random())
	id_poke.text = slot_id
	sprite.modulate = 0
	
	sprite_path = data.load_sprite(slot_id, 0)
	sprite.texture = load(sprite_path)
