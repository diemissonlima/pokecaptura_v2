extends TextureRect
class_name Pokedex

const _POKEDEX_KANTO_SIZE: int = 151
const _POKEDEX_JOHTO_SIZE: int = 100
const _POKEDEX_HOENN_SIZE: int = 135

const _POKEDEX_SIZE: int = 386
const _POKEDEX_SLOT: PackedScene = preload("res://scenes/interface/slot.tscn")

@export_category("Objetos")
@export var dex_kanto_container: GridContainer
@export var dex_johto_container: GridContainer
@export var dex_hoenn_container: GridContainer
@export var info_pokemon: TextureRect

@export_category("Obejtos InfoPokedex")
@export var title: Label
@export var seen_title: Label
@export var catch_title: Label
@export var sprite: TextureRect
@export var primary_type: TextureRect
@export var secondary_type: TextureRect
@export var id_poke: Label
@export var poke_name: Label
@export var catch: Label
@export var seen: Label
@export var catch_shiny: Label
@export var seen_shiny: Label
@export var dex_description: Label
@export var info_local: Label


var slot_can_click: bool = false
var _slot_id: String = ""


func _ready() -> void:
	spawn_slot()
	show_pokemon_on_ready_scene()
	
	for slot in get_tree().get_nodes_in_group("slot"): # for pra conectar o sinal de mouse entered/exited no slot
		slot.mouse_entered.connect(on_mouse_entered.bind(slot.slot_id)) # sinal conectado com base no ID do slot
		slot.mouse_exited.connect(on_mouse_exited.bind(slot.slot_id))
		
	for button in $GenButtonContainer.get_children():
		button.pressed.connect(switch_dex_button_pressed.bind(button.name))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pokedex_info"):
		update_pokedex_progress()
		visible = not visible
		info_pokemon.hide()
		
	if Input.is_action_just_pressed("mouse_left_click") and slot_can_click: # verifica e habilita para o slot ser clicado
		details_pokemon(SQL.info_pokedex(_slot_id)) # envia o Slot ID para a função que vai mostrar os dados do pokemon na pokedex


func spawn_slot() -> void:
	var index: int = 0
	for j in _POKEDEX_KANTO_SIZE:
		index += 1
		var slot = _POKEDEX_SLOT.instantiate()
		
		if index <= 9:
			slot.slot_id = "00" + str(index)
		elif index >= 10 and index <= 99:
			slot.slot_id = "0" + str(index)
		elif index >= 100:
			slot.slot_id = str(index)
			
		dex_kanto_container.add_child(slot)
	
	for j in _POKEDEX_JOHTO_SIZE:
		index += 1
		var slot = _POKEDEX_SLOT.instantiate()
		slot.slot_id = str(index)
		
		dex_johto_container.add_child(slot)
		
	for j in _POKEDEX_HOENN_SIZE:
		index += 1
		var slot = _POKEDEX_SLOT.instantiate()
		slot.slot_id = str(index)
		
		dex_hoenn_container.add_child(slot)


func update_pokedex_progress() -> void:
	seen_title.text = "Visto: " + str(SQL.return_pokedex_progress()[0])
	catch_title.text = "Capturado: " + str(SQL.return_pokedex_progress()[1])


func show_pokemon_on_ready_scene() -> void:
	var region_dict: Dictionary = {
		"Kanto": dex_kanto_container,
		"Johto": dex_johto_container,
		"Hoenn": dex_hoenn_container
	}
	
	var region: String
	
	for slot in region_dict.values():
		var target_slot = slot.get_children()
		
		for j in target_slot:
			var new_id = int(j.slot_id)
			if new_id <= 151:
				region = "Kanto"
			elif new_id > 151 and new_id <= 252:
				region = "Johto"
			elif new_id > 252 and new_id <= 386:
				region = "Hoenn"
			
		for i in region_dict[region].get_children():
			if SQL.verify_pokemon_captured(i.slot_id) == 1:
				show_pokemon(i.slot_id, "visto", region)
				
			elif SQL.verify_pokemon_captured(i.slot_id) == 2:
				show_pokemon(i.slot_id, "capturado", region)


func show_pokemon(id: String, status: String, region: String) -> void:
	var region_dict: Dictionary = {
		"Kanto": dex_kanto_container,
		"Johto": dex_johto_container,
		"Hoenn": dex_hoenn_container
	}
	
	for slot in region_dict[region].get_children():
		if slot.slot_id == id:
			slot.id_poke.show()
			match status:
				"visto":
					slot.sprite.modulate = 255 # mostra a silhueta do pokemon
					
				"capturado":
					slot.sprite.modulate = -1 # mostra o pokemon completo


func details_pokemon(info: Dictionary) -> void:
	if info["status_pokedex"] == 0: # 0 quer dizer que o pokemon nao foi visto e nem capturado e oculta o sprite na pokedex
		return
	elif info["status_pokedex"] == 1: # 1 quer dizer que o pokemon foi apenas visto, mostrando so a silhueta dele na pokedex
		sprite.modulate = 255
	elif info["status_pokedex"] == 2: # 2 quer dizer que pokemon foi registrado na pokedex, mostrando assim a imagem dele completa
		sprite.modulate = -1
		
	info_pokemon.show()
	title.text = info["nome"].to_upper()
	id_poke.text = info["id"]
	primary_type.texture = load(show_type_pokemon(info["primary_type"]))
	
	if info["primary_type"] == info["secondary_type"]: # caso seja atendida significa que o pokemon nao tem um tipo secundario
		secondary_type.hide() # entao é ocultado 
	else:
		secondary_type.show()
		secondary_type.texture = load(show_type_pokemon(info["secondary_type"]))
		
	sprite.texture = load(load_sprite(info["id"]))
	
	poke_name.text = info["nome"]
	catch.text = str(info["capturado"])
	seen.text = str(info["visto"])
	catch_shiny.text = str(info["shiny_capturado"])
	seen_shiny.text = str(info["shiny_visto"])
	dex_description.text = info["desc_pokedex"]
	info_local.text = "Pode ser encontrado no Mapa " + info["mapa"]


func show_type_pokemon(type: String) -> String:
	var type_texture_path: String = "res://assets/prefabs/pokemon_type/" + type.to_lower() + ".png"
	return type_texture_path
	
	
func load_sprite(slot_id: String) -> String:
	var gen: String = ""
	var new_slot_id: int
	var sprite_path: String
	
	new_slot_id = int(slot_id)
	
	if new_slot_id <= 151:
		gen = "gen1"
	elif new_slot_id > 151 and new_slot_id <= 251:
		gen = "gen2"
	elif new_slot_id > 251 and new_slot_id <= 386:
		gen = "gen3"

	sprite_path = "res://assets/pokemon_sprite/" + gen + "/normal/" + slot_id + ".png"

	return sprite_path


func on_mouse_entered(slot_id: String) -> void:
	slot_can_click = true # booleano pra determinado quando o slot pode ser clicado
	_slot_id = slot_id # slot ID enviado pelo for e atribui a uma variavel global
	

func on_mouse_exited(_slot_id: String) -> void:
	slot_can_click = false
	_slot_id = ""


func switch_dex_button_pressed(button_name: String) -> void:
	match button_name:
		"Kanto":
			$ScrollContainer/DexKantoContainer.show()
			$ScrollContainer/DexJohtoContainer.hide()
			$ScrollContainer/DexHoennContainer.hide()
			
		"Johto":
			$ScrollContainer/DexKantoContainer.hide()
			$ScrollContainer/DexJohtoContainer.show()
			$ScrollContainer/DexHoennContainer.hide()
			
		"Hoenn":
			$ScrollContainer/DexKantoContainer.hide()
			$ScrollContainer/DexJohtoContainer.hide()
			$ScrollContainer/DexHoennContainer.show()


func _on_button_pressed() -> void:
	info_pokemon.hide()
