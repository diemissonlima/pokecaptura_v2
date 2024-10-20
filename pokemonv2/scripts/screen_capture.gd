extends Control
class_name ScreenCapture

@export_category("Objetos")
@export var pokemon_position: Marker2D
@export var background: TextureRect
@export var options_container: HBoxContainer
@export var text_box: TextureRect
@export var info_captura: Label
@export var rewards_info: Label

@export_category("Pokeballs")
@export var button_pokeball: TextureButton
@export var pokeball_label: Label
@export var button_greatball: TextureButton
@export var greatball_label: Label
@export var button_ultraball: TextureButton
@export var ultraball_label: Label
@export var button_repeatball: TextureButton
@export var repeatball_label: Label
@export var button_heavyball: TextureButton
@export var heavyball_label: Label
@export var button_masterball: TextureButton
@export var masterball_label: Label

var pokemon_captured
var pokeball_rate: float


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_on_screen_capture"):
		button.pressed.connect(on_button_pressed.bind(button.name))
	
	update_label_pokeball()


func _process(_delta: float) -> void:
	show_pokeball_button()


func get_texture_path(path: String) -> void:
	background.texture = load(path)


func get_pokemon(_pokemon: CharacterBody2D, poke_position: Marker2D) -> void:
	pokemon_captured = _pokemon
	add_child(pokemon_captured)
	pokemon_position = poke_position
	pokemon_captured.position = pokemon_position.position


func set_capture(_pokeball_used: String) -> void:
	var random_number: float = randf()
	var chance_of_capture: float = (pokemon_captured.catch_rate / 255) * pokeball_rate
	
	await get_tree().create_timer(1.5).timeout
	
	if random_number <= chance_of_capture or chance_of_capture >= 1.0:
		if pokemon_captured.shiny:
			SQL.update_pokemon(pokemon_captured.id_dex, "shiny_capturado")
		else:
			SQL.update_pokemon(pokemon_captured.id_dex, "capturado")
		
		if pokemon_captured.secondary_type == pokemon_captured.primary_type:
			get_tree().call_group("achievements", "update_achievement", pokemon_captured.primary_type)
		else:
			get_tree().call_group("achievements", "update_achievement", pokemon_captured.primary_type)
			get_tree().call_group("achievements", "update_achievement", pokemon_captured.secondary_type)
		
		get_tree().call_group("mapa", "update_map_progress")
		get_tree().call_group("pokedex_info", "show_pokemon", pokemon_captured.id_dex, "capturado", pokemon_captured.region)
		
		info_captura.text = "Pokemon Capturado!\nDrop: " + str(pokemon_captured.dropped_credit) + " Créditos"
		
		SQL.add_pokemon_to_bank(pokemon_captured)
		get_tree().call_group("pokemon_bank", "add_pokemon_to_bank")
		
		drop(pokemon_captured.dropped_credit)
		
		if QuestUpdate.active_quests.size() > 0:
			var tipo_1 = pokemon_captured.primary_type
			var tipo_2 = pokemon_captured.secondary_type
			
			if QuestUpdate.active_quests.size() != 0:
				QuestUpdate.on_item_collected(
					pokemon_captured.primary_type,
					pokemon_captured.secondary_type
				)
		
	else:
		
		info_captura.text = "Pokemon Escapou!!! Tentar Captura Novamente?"
		$Background/Sim.show()
		$Background/Nao.show()

	text_box.show()


func drop(value: int) -> void:
	SQL.update_database("inventario", "Credito", "increase", value)


func show_pokeball_button() -> void:
	var pokeball_list: Dictionary = {
		"pokeball": [
			button_pokeball, pokeball_label
		],
		
		"greatball": [
			button_greatball, greatball_label
		],
		
		"ultraball": [
			button_ultraball, ultraball_label
		],
		
		"masterball": [
			button_masterball, masterball_label
		],
		
		"repeatball": [
			button_repeatball, repeatball_label
		],
		
		"heavyball": [
			button_heavyball, heavyball_label
		]
	}
	
	for button in pokeball_list.values():
		if int(button[1].text) <= 0:
			button[0].hide()
			button[1].hide()
		else:
			button[0].show()
			button[1].show()


func update_label_pokeball() -> void:
	pokeball_label.text = str(SQL.verify_item_amount_on_inventory("Pokeball"))
	greatball_label.text = str(SQL.verify_item_amount_on_inventory("Greatball"))
	ultraball_label.text = str(SQL.verify_item_amount_on_inventory("Ultraball"))
	repeatball_label.text = str(SQL.verify_item_amount_on_inventory("Repeatball"))
	heavyball_label.text = str(SQL.verify_item_amount_on_inventory("Heavyball"))
	masterball_label.text = str(SQL.verify_item_amount_on_inventory("Masterball"))


func show_quest_rewards(quest_info: Array) -> void:
	var quest_name = quest_info[0][0]
	var quest_item = quest_info[0][1]
	var quest_amount = quest_info[0][2]
	
	rewards_info.text = "Quest " + quest_name + " Completada! Recompensa: " + str(quest_amount) + " " + quest_item + "!" 
	rewards_info.show()


func notify_achievement_levelup(type: String, rewards: Array) -> void:
	rewards_info.text = "Marco do tipo " + type + " subiu de nível!\nRecompensa:\n" + str(rewards[1]) + " " + rewards[0]
	rewards_info.show()
	
	SQL.update_database("inventario", rewards[0], "increase", rewards[1])
	
	update_label_pokeball()


func _on_quit_pressed() -> void:
	$Background/TryAgain.hide()
	$Background/Sim.hide()
	$Background/Nao.hide()
	rewards_info.hide()
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
			
		"Greatball":
			pokeball_rate = 1.5
	
		"Ultraball":
			pokeball_rate = 2.0
			
		"Repeatball":
			if pokemon_captured.info_catch.modulate.a == 1.0:
				pokeball_rate = 3.0
			else:
				pokeball_rate = 1.0
				
		"Heavyball":
			if pokemon_captured.weight <= 50:
				pokeball_rate = 0.5
			elif pokemon_captured.weight > 50 and pokemon_captured.weight <= 150:
				pokeball_rate = 1.0
			elif pokemon_captured.weight > 150 and pokemon_captured.weight <= 300:
				pokeball_rate = 2.0
			elif pokemon_captured.weight > 300 and pokemon_captured.weight <= 450:
				pokeball_rate = 3.0
			elif pokemon_captured.weight > 450 and pokemon_captured.weight <= 600:
				pokeball_rate = 4.0
			elif pokemon_captured.weight > 600 and pokemon_captured.weight <= 750:
				pokeball_rate = 5.0
			elif pokemon_captured.weight > 750 and pokemon_captured.weight <= 900:
				pokeball_rate = 6.0
			elif pokemon_captured.weight > 900:
				pokeball_rate = 7.0
			
		"Masterball":
			pokeball_rate = 51.0
	
	update_label_pokeball()
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
