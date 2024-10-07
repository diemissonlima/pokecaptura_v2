extends Control
class_name Slot

@export_category("Variaveis")
@export var slot_id: String
@export var background_list: Array[String]

@export_category("Obejtos")
@export var sprite: TextureRect
@export var background: TextureRect
@export var id_poke: Label

var gen: String = ""


func _ready() -> void:
	background.texture = load(background_list.pick_random())
	id_poke.text = slot_id
	sprite.modulate = 0
	
	load_sprite()


func load_sprite() -> void:
	var new_slot_id: int
	new_slot_id = int(slot_id)
	
	if new_slot_id <= 151:
		gen = "gen1"
	elif new_slot_id > 151 and new_slot_id <= 251:
		gen = "gen2"
	elif new_slot_id > 251 and new_slot_id <= 386:
		gen = "gen3"
	elif new_slot_id > 386 and new_slot_id <= 493:
		gen = "gen4"
	
	sprite.texture = load("res://assets/pokemon_sprite/" + gen + "/normal/" + slot_id + ".png")
