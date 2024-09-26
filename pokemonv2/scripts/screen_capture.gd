extends Control
class_name ScreenCapture

@export_category("Objetos")
@export var pokemon_position: Marker2D
@export var background: TextureRect
@export var options_container: HBoxContainer
@export var text_box: TextureRect
@export var info_captura: Label
@export var pokeball_label: Label
@export var greatball_label: Label
@export var ultraball_label: Label
@export var masterball_label: Label

var pokemon_captured
var pokeball_rate: float


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_on_screen_capture"):
		button.pressed.connect(on_button_pressed.bind(button.name))
		
	pokeball_label.text = str(SQL.verify_item_amount_on_inventory("Pokeball"))
	greatball_label.text = str(SQL.verify_item_amount_on_inventory("Greatball"))
	ultraball_label.text = str(SQL.verify_item_amount_on_inventory("Ultraball"))
	masterball_label.text = str(SQL.verify_item_amount_on_inventory("Masterball"))


func get_texture_path(path: String) -> void:
	background.texture = load(path)


func get_pokemon(_pokemon: CharacterBody2D, poke_position: Marker2D) -> void:
	pokemon_captured = _pokemon
	add_child(pokemon_captured)
	pokemon_position = poke_position
	pokemon_captured.position = pokemon_position.position


func set_capture(_pokeball_used: String) -> void:
	update_label_pokeball()
	
	var random_number: float = randf()
	var chance_of_capture: float = (pokemon_captured.catch_rate / 255) * pokeball_rate
	
	await get_tree().create_timer(1.5).timeout
	
	if random_number <= chance_of_capture or chance_of_capture >= 1.0:
		if pokemon_captured.shiny:
			SQL.update_pokemon(pokemon_captured.id_dex, "shiny_capturado")
		else:
			SQL.update_pokemon(pokemon_captured.id_dex, "capturado")
			
		# SQL.update_database("estatisticas", "pokemon_capturado", "increase", 1)
		get_tree().call_group("pokedex_info", "show_pokemon", pokemon_captured.id_dex, "capturado")
		
		info_captura.text = "Pokemon Capturado!\nDrop: " + str(pokemon_captured.dropped_credit) + " Créditos"
		
		SQL.add_pokemon_to_bank(pokemon_captured)
		drop(pokemon_captured.dropped_credit)
		
		if QuestUpdate.active_quests.size() > 0:
			var tipo_1 = pokemon_captured.primary_type
			var tipo_2 = pokemon_captured.secondary_type
			
			for quest in QuestUpdate.active_quests:
				if tipo_1 == quest.quest_type.capitalize() or tipo_2 == quest.quest_type.capitalize():
					QuestUpdate.on_item_collected(quest.quest_name)
		
	else:
		# SQL.update_database("estatisticas", "pokemon_perdido", "increase", 1)
		
		info_captura.text = "Pokemon Escapou!!! Tentar Captura Novamente?"
		$Background/Sim.show()
		$Background/Nao.show()

	text_box.show()


func drop(value: int) -> void:
	SQL.update_database("inventario", "Credito", "increase", value)


func update_label_pokeball() -> void:
	pokeball_label.text = str(SQL.verify_item_amount_on_inventory("Pokeball"))
	greatball_label.text = str(SQL.verify_item_amount_on_inventory("Greatball"))
	ultraball_label.text = str(SQL.verify_item_amount_on_inventory("Ultraball"))
	masterball_label.text = str(SQL.verify_item_amount_on_inventory("Masterball"))


func _on_quit_pressed() -> void:
	$Background/TryAgain.hide()
	$Background/Sim.hide()
	$Background/Nao.hide()
	text_box.hide()
	options_container.show()
	pokemon_captured.queue_free()
	self.hide()


func on_button_pressed(button_name: String) -> void:
	if SQL.verify_item_amount_on_inventory(button_name) <= 0:
		return
		
	options_container.hide()
	info_captura.text = "Tentando Captura!!"
	text_box.show()
	
	SQL.update_database("inventario", button_name, "decrease", 1)
	
	match button_name:
		"Pokeball":
			pokeball_rate = 1.0
			pokeball_label.text = str(SQL.verify_item_amount_on_inventory(button_name))
			
		"Greatball":
			pokeball_rate = 1.5
			greatball_label.text = str(SQL.verify_item_amount_on_inventory(button_name))
	
		"Ultraball":
			pokeball_rate = 2.0
			ultraball_label.text = str(SQL.verify_item_amount_on_inventory(button_name))
			
		"Masterball":
			pokeball_rate = 51.0
			masterball_label.text = str(SQL.verify_item_amount_on_inventory(button_name))
	
	set_capture(button_name)


func _on_try_again_sim_pressed() -> void:
	text_box.hide()
	$Background/TryAgain.hide()
	$Background/Sim.hide()
	$Background/Nao.hide()
	options_container.show()


func _on_try_again_nao_pressed() -> void:
	$Background/TryAgain.hide()
	$Background/Sim.hide()
	$Background/Nao.hide()
	text_box.hide()
	options_container.show()
	pokemon_captured.queue_free()
	self.hide()
