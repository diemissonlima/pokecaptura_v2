extends TextureRect

const SLOT_BANK: PackedScene = preload("res://scenes/interface/slot_bank.tscn")

@export_category("Objetos")
@export var bank_container: GridContainer
@export var sprite: TextureRect
@export var pokemon_name: Label
@export var option_button: OptionButton

@export_category("Variaveis")
@export var sprite2: TextureRect
@export var sprite3: TextureRect
@export var dex_number: Label
@export var pokemon_id: Label
@export var nature: Label
@export var nature_description: Label
@export var primary_type: TextureRect
@export var secondary_type: TextureRect
@export var weight: Label
@export var data_captura: Label
@export var ability_name: Label
@export var ability_description: Label

var can_click: bool = false
var poke_bank: Array = []
var bank_size: int

var id_slot: int = 0
var pokemon_info: Dictionary = {}


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit") and visible:
		sprite.texture = null
		pokemon_name.text = ""
		pokemon_info.clear()
		option_button.select(-1)
		$ScrollContainer.show()
		$Background.show()
		$PokemonEntry.hide()
		
		for slot in bank_container.get_children():
			slot.show()
			
		visible = false
		
	if Input.is_action_just_pressed("mouse_left_click") and can_click:
		get_slot_info()
		
	if Input.is_action_just_pressed("info_pokemon") and sprite.texture != null:
		$ScrollContainer.hide()
		$Background.hide()
		$PokemonEntry.show()
		
		set_info()


func _ready() -> void:
	poke_bank = SQL.info_bank()
	bank_size = poke_bank.size()
	spawn_slot_onready_scene()
	
	if bank_size == 0:
		return
		
	for poke in poke_bank:
		load_pokemon_on_bank(poke)
	
	connect_button_signal()
	load_pokemon_on_party()


func set_info() -> void:
	sprite2.texture = load(data.load_sprite(pokemon_info["numero_dex"], pokemon_info["shiny"]))
	sprite3.texture = load(data.load_sprite(pokemon_info["numero_dex"], pokemon_info["shiny"]))
	dex_number.text = "Dex N°: " + pokemon_info["numero_dex"]
	pokemon_id.text = "ID: " + str(pokemon_info["id_pokemon"]) + " - " + pokemon_info["nome"]
	nature.text = "Nature: " + pokemon_info["nature"]
	primary_type.texture = load("res://assets/prefabs/pokemon_type/" + pokemon_info["primary_type"].to_lower() + ".png")
	
	if pokemon_info["primary_type"] == pokemon_info["secondary_type"]:
		secondary_type.hide()
	else:
		secondary_type.show()
		secondary_type.texture = load("res://assets/prefabs/pokemon_type/" + pokemon_info["secondary_type"].to_lower() + ".png")
	
	data_captura.text = "Catch: " + pokemon_info["data_captura"] + " " + pokemon_info["hora_captura"]
	weight.text = "Peso: " + str(pokemon_info["weight"]) + " Kg"
	ability_name.text = "Habilidade: " + pokemon_info["ability"]
	ability_description.text = pokemon_info["ability_description"]


func connect_button_signal() -> void:
	for slot in get_tree().get_nodes_in_group("slot_bank"): # for pra conectar o sinal de mouse entered/exited no slot
		slot.mouse_entered.connect(on_mouse_entered.bind(slot.id)) # sinal conectado com base no ID do slot
		slot.mouse_exited.connect(on_mouse_exited.bind(slot.id))


func spawn_slot_onready_scene() -> void:
	for j in bank_size:
		var slot = SLOT_BANK.instantiate()
		bank_container.add_child(slot)


func load_pokemon_on_bank(poke_info: Dictionary) -> void:
	for slot in bank_container.get_children():
		if slot.id == 0:
			slot.sprite.texture = load(data.load_sprite(poke_info["numero_dex"], poke_info["shiny"]))
			slot.id = poke_info["id_pokemon"]
			slot.name_pokemon = poke_info["nome"]
			slot.dex_number = poke_info["numero_dex"]
			slot.ability = poke_info["ability"]
			slot.shiny = poke_info["shiny"]
			break


func load_pokemon_on_party() -> void:
	var pokemon_in_party: Array = []
	SQL.db.query(
		"SELECT * FROM banco_pokemon WHERE in_party = 1"
	)
	
	for poke in SQL.db.query_result:
		pokemon_in_party.append(poke)
	
	get_tree().call_group("mapa", "add_party_onready_scene", pokemon_in_party)


func add_pokemon_to_bank() -> void:
	var slot = SLOT_BANK.instantiate()
	bank_container.add_child(slot)
	
	var poke_info: Dictionary = {}
	poke_bank.clear()
	poke_bank = SQL.info_bank()

	if poke_bank.size() != 0:
		poke_info = poke_bank[-1]
	
	load_pokemon_on_bank(poke_info)
	
	slot.mouse_entered.connect(on_mouse_entered.bind(slot.id))
	slot.mouse_exited.connect(on_mouse_exited.bind(slot.id))


func get_slot_info() -> void:
	SQL.db.query(
		"SELECT * FROM banco_pokemon WHERE id_pokemon = '" + str(id_slot) + "'"
	)
	
	pokemon_info = SQL.db.query_result[0]
	
	pokemon_name.text = pokemon_info["nome"]
	sprite.texture = load(data.load_sprite(pokemon_info["numero_dex"], pokemon_info["shiny"]))
	
	if pokemon_info["shiny"]:
		$Background/IsShiny.show()
	else:
		$Background/IsShiny.hide()


func on_mouse_entered(id: int) -> void:
	can_click = true
	id_slot = id


func on_mouse_exited(_id: int) -> void:
	can_click = false


func _on_quit_pressed() -> void:
	$PokemonEntry.hide()
	$ScrollContainer.show()
	$Background.show()
	pokemon_info.clear()
	sprite.texture = null
	pokemon_name.text = ""


func _on_add_party_pressed() -> void:
	get_tree().call_group("mapa", "add_party", pokemon_info)
	get_tree().call_group("slot_bank", "update_on_companion", pokemon_info["id_pokemon"], "add")


func _on_option_button_item_selected(index: int) -> void:
	var option_list: Array = [
		"Todos",
		"Bargainer", "Steady Hand (Pokeball)", "Steady Hand (Greatball)",
		"Steady Hand (Ultraball)", "Fortune Finder", "Synchronize",
		"Pokéball Expert", "Conservationist", "Resourceful", "Shiny Hunter"
	]
	
	if index == 0:
		for slot in bank_container.get_children():
			slot.show()
			
	else:
		for slot in bank_container.get_children():
			if slot.ability == option_list[index]:
				slot.show()
			else:
				slot.hide()
