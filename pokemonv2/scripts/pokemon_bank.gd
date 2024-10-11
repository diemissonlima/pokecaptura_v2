extends TextureRect

const SLOT_BANK: PackedScene = preload("res://scenes/interface/slot_bank.tscn")

@export_category("Objetos")
@export var bank_container: GridContainer

var can_click: bool = false
var poke_bank: Array = []
var bank_size: int


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("bank"):
		visible = not visible


func _ready() -> void:
	for slot in get_tree().get_nodes_in_group("slot_bank"): # for pra conectar o sinal de mouse entered/exited no slot
		slot.mouse_entered.connect(on_mouse_entered.bind(slot.id)) # sinal conectado com base no ID do slot
		#slot.mouse_exited.connect(on_mouse_exited.bind(slot.slot_id))
	
	poke_bank = SQL.info_bank()
	bank_size = poke_bank.size()
	spawn_slot_onready_scene()
	
	for poke in poke_bank:
		load_pokemon_on_bank(poke)


func spawn_slot_onready_scene() -> void:
	for j in bank_size:
		var slot = SLOT_BANK.instantiate()
		bank_container.add_child(slot)


func load_pokemon_on_bank(poke_info: Dictionary) -> void:
	for slot in bank_container.get_children():
		if slot.id == 0:
			slot.sprite.texture = load(load_sprite(poke_info["numero_dex"]))
			slot.id = poke_info["id_pokemon"]
			slot.date_capture = poke_info["data_captura"]
			slot.time_capture = poke_info["hora_captura"]
			slot.dex_number = poke_info["numero_dex"]
			slot.name_pokemon = poke_info["nome"]
			slot.primary_type = poke_info["primary_type"]
			slot.secondary_type = poke_info["secondary_type"]
			slot.region = poke_info["region"]
			slot.nature = poke_info["nature"]
			
			break


func load_sprite(dex_number: String) -> String:
	var new_slot_id: int
	var sprite_path: String
	var gen: String
	
	new_slot_id = int(dex_number)
	
	if new_slot_id <= 151:
		gen = "gen1"
	elif new_slot_id > 151 and new_slot_id <= 251:
		gen = "gen2"
	elif new_slot_id > 251 and new_slot_id <= 386:
		gen = "gen3"
	elif new_slot_id > 386 and new_slot_id <= 493:
		gen = "gen4"
	
	sprite_path = "res://assets/pokemon_sprite/" + gen + "/normal/" + dex_number + ".png"
	return sprite_path


func add_pokemon_to_bank() -> void:
	var slot = SLOT_BANK.instantiate()
	bank_container.add_child(slot)
	
	var poke_info: Dictionary = {}
	poke_bank.clear()
	poke_bank = SQL.info_bank()
	poke_info = poke_bank[-1]
	
	load_pokemon_on_bank(poke_info)


func on_mouse_entered(id: int) -> void:
	pass
