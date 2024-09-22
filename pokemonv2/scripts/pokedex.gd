extends TextureRect
class_name Pokedex

@export_category("Objetos")
@export var dex_container: GridContainer
@export var info_pokemon: TextureRect

@export_category("Obejtos InfoPokedex")
@export var title: Label
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


var slot_can_click: bool = false
var _slot_id: String = ""


func _ready() -> void:
	for slot in dex_container.get_children():
		if SQL.verify_pokemon_captured(slot.slot_id) == 1:
			show_pokemon(slot.slot_id, "visto")
			
		elif SQL.verify_pokemon_captured(slot.slot_id) == 2:
			show_pokemon(slot.slot_id, "capturado")
			
	for slot in get_tree().get_nodes_in_group("slot"): # for pra conectar o sinal de mouse entered/exited no slot
		slot.mouse_entered.connect(on_mouse_entered.bind(slot.slot_id)) # sinal conectado com base no ID do slot
		slot.mouse_exited.connect(on_mouse_exited.bind(slot.slot_id))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pokedex_info"):
		visible = not visible
		info_pokemon.hide()
		
	if Input.is_action_just_pressed("mouse_left_click") and slot_can_click: # verifica e habilita para o slot ser clicado
		details_pokemon(SQL.info_pokedex(_slot_id)) # envia o Slot ID para a função que vai mostrar os dados do pokemon na pokedex


func show_pokemon(id: String, status: String) -> void:
	for slot in dex_container.get_children():
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

	sprite_path = "res://assets/pokemon_sprite/" + gen + "/normal/" + slot_id + ".png"

	return sprite_path


func on_mouse_entered(slot_id: String) -> void:
	slot_can_click = true # booleano pra determinado quando o slot pode ser clicado
	_slot_id = slot_id # slot ID enviado pelo for e atribui a uma variavel global
	

func on_mouse_exited(_slot_id: String) -> void:
	slot_can_click = false
	_slot_id = ""


func _on_button_pressed() -> void:
	info_pokemon.hide()
