extends Control
class_name BaseMap


@export_category("Objetos")
@export var spawn_position: Marker2D
@export var spawn_timer: Timer
@export var screen_capture: Control
@export var background: TextureRect
@export var options_container: HBoxContainer
@export var options_container2: GridContainer
@export var button_start_hunting: Button
@export var info: Label
@export var info2: Label
@export var spawn_lendario: Label
@export var map_name_label: Label
@export var progress_map_bar: ProgressBar

@export_category("Objetos Party Container")
@export var party_container: HBoxContainer

@export_category("Objetos Interface")
@export var pokedex: TextureRect
@export var pokemon_bank: TextureRect
@export var achievements: Control
@export var quest_panel: Control
@export var pokemon_shop: Control
@export var companion: Control

@export_category("Variaveis")
@export var map_name: String
@export var pokemon_list: Array[PackedScene]
@export var pokemon_legendary_list: Array[PackedScene]
@export var path_background: String

@export_category("SpawnPokemonTeste")
@export var commom_list: Array[PackedScene]
@export var incommom_list: Array[PackedScene]
@export var rare_list: Array[PackedScene]

var pokemon_spawned
var party_slot_can_click: bool = false

var target_slot: Control


func _ready() -> void:
	map_name_label.text = "Mapa " + map_name
	
	get_tree().call_group("screen_capture", "get_texture_path", path_background)
	spawn_legendary()
	
	update_map_progress()
	
	for slot in party_container.get_children():
		slot.mouse_entered.connect(on_mouse_entered.bind(slot))
		slot.mouse_entered.connect(on_mouse_exited.bind(slot))
		
	for button in options_container2.get_children():
		button.pressed.connect(on_button_pressed.bind(button.name))


func _process(_delta: float) -> void:
	$Background/QuestInProgress.text = "Quests Ativas: " + str(QuestUpdate.active_quests.size()) + " / 3"

	update_progress_quest_label()


func update_map_progress() -> void:
	var progress_map = SQL.verify_map_progress(map_name)
	
	progress_map_bar.max_value = progress_map[0]
	progress_map_bar.value = progress_map[1]


func spawn_legendary() -> void:
	var random_number: float = randf()
	var probability: float = 0.1
	
	if random_number <= probability:
		var pokemon_legendary = pokemon_legendary_list.pick_random()
		pokemon_list.append(pokemon_legendary)
		
		spawn_lendario.show()
		await get_tree().create_timer(5.0).timeout
		spawn_lendario.hide()


func spawn_pokemon() -> void:
	pokemon_spawned = pokemon_list.pick_random().instantiate()
	pokemon_spawned.global_position = spawn_position.global_position
	pokemon_spawned.scale = Vector2(0.7, 0.7)
	get_tree().root.call_deferred("add_child", pokemon_spawned)


func spawn_pokemon2() -> void:
	var random_number: int = randi_range(1, 100)
	
	if random_number >= 1 and random_number <= 50:
		pokemon_spawned = commom_list.pick_random().instantiate()
	elif random_number > 50 and random_number <= 85:
		pokemon_spawned = incommom_list.pick_random().instantiate()
	elif random_number > 85:
		pokemon_spawned = rare_list.pick_random().instantiate()
	
	pokemon_spawned.global_position = spawn_position.global_position
	pokemon_spawned.scale = Vector2(0.7, 0.7)
	get_tree().root.call_deferred("add_child", pokemon_spawned)


func _on_start_hunting_pressed() -> void:
	button_start_hunting.hide()
	info2.show()
	spawn_timer.start()


func _on_sim_pressed() -> void:
	pokemon_spawned.get_parent().remove_child(pokemon_spawned)
	get_tree().call_group("screen_capture", "get_pokemon", pokemon_spawned, spawn_position)
	screen_capture.show()
	info.hide()
	options_container.hide()
	button_start_hunting.show()


func _on_nao_pressed() -> void:
	pokemon_spawned.queue_free()
	info.hide()
	options_container.hide()
	button_start_hunting.show()


func _on_spawn_timer_timeout() -> void:
	info2.hide()
	spawn_pokemon()
	
	await get_tree().create_timer(0.1).timeout

	if pokemon_spawned.shiny:
		info.text = "Você encontrou um SHINY " + pokemon_spawned.pokemon_name + "! Deseja Captura-lo?"
		SQL.update_pokemon(pokemon_spawned.id_dex, "shiny_visto")
		
	else:
		info.text = "Você encontrou um " + pokemon_spawned.pokemon_name + "! Deseja Captura-lo?"
		SQL.update_pokemon(pokemon_spawned.id_dex, "visto")
	
	info.show()
	options_container.show()

	if SQL.verify_pokemon_captured(pokemon_spawned.id_dex) == 2:
			return
			
	get_tree().call_group("pokedex_info", "show_pokemon", pokemon_spawned.id_dex, "visto", pokemon_spawned.region)


func update_progress_quest_label() -> void:
	var quest_list: Array = QuestUpdate.active_quests.duplicate()
	
	if quest_list.size() == 0:
		$Background/VBoxContainer/Quest1.text = "" 
		$Background/VBoxContainer/Quest2.text = ""
		$Background/VBoxContainer/Quest3.text = ""
		
	if quest_list.size() == 1:
		$Background/VBoxContainer/Quest1.text = "- " + quest_list[0]["name"] + "
		Capture " + str(quest_list[0]["objective"]) + " Pokémon do tipo " + quest_list[0]["type"].to_upper() + "
		" + str(quest_list[0]["progress"]) + " / " + str(quest_list[0]["objective"])
		$Background/VBoxContainer/Quest2.text = ""
		$Background/VBoxContainer/Quest3.text = ""
	
	if quest_list.size() == 2:
		$Background/VBoxContainer/Quest1.text = "- " + quest_list[0]["name"] + "
		Capture " + str(quest_list[0]["objective"]) + " Pokémon do tipo " + quest_list[0]["type"].to_upper() + "
		" + str(quest_list[0]["progress"]) + " / " + str(quest_list[0]["objective"])
		$Background/VBoxContainer/Quest2.text = "- " + quest_list[1]["name"] + "
		Capture " + str(quest_list[1]["objective"]) + " Pokémon do tipo " + quest_list[1]["type"].to_upper() + "
		"  + str(quest_list[1]["progress"]) + " / " + str(quest_list[1]["objective"])
		$Background/VBoxContainer/Quest3.text = ""
		
	if quest_list.size() == 3:
		$Background/VBoxContainer/Quest1.text = "- " + quest_list[0]["name"] + "
		Capture " + str(quest_list[0]["objective"]) + " Pokémon do tipo " + quest_list[0]["type"].to_upper() + "
		" + str(quest_list[0]["progress"]) + " / " + str(quest_list[0]["objective"])
		$Background/VBoxContainer/Quest2.text = "- " + quest_list[1]["name"] + "
		Capture " + str(quest_list[1]["objective"]) + " Pokémon do tipo " + quest_list[1]["type"].to_upper() + "
		" + str(quest_list[1]["progress"]) + " / " + str(quest_list[1]["objective"])
		$Background/VBoxContainer/Quest3.text = "- " + quest_list[2]["name"] + "
		Capture " + str(quest_list[2]["objective"]) + " Pokémon do tipo " + quest_list[2]["type"].to_upper() + "
		" + str(quest_list[2]["progress"]) + " / " + str(quest_list[2]["objective"])


func add_party_onready_scene(party_list: Array) -> void:
	for poke in party_list:
		add_party(poke)
		get_tree().call_group("slot_bank", "update_on_companion", poke["id_pokemon"], "add")


func add_party(poke_info: Dictionary) -> void:
	for slot in party_container.get_children():
		if slot.sprite.texture == null:
			slot.sprite.texture = load(data.load_sprite(poke_info["numero_dex"], poke_info["shiny"]))
			slot.id_pokemon = poke_info["id_pokemon"]
			data.companion = poke_info.duplicate()
			
			SQL.db.query(
				"UPDATE banco_pokemon SET in_party = 1 WHERE id_pokemon = " + str(poke_info["id_pokemon"])
			)
			
			break
			
		else:
			for slot1 in party_container.get_children():
				if slot1.id_pokemon == poke_info["id_pokemon"]:
					return


func _on_expand_pressed() -> void:
	if $Background/Expand.rotation == 0:
		$Background/Expand.set_rotation(1.57)
		
		$Background/VBoxContainer.show()
	else:
		$Background/Expand.set_rotation(0.0)
		$Background/VBoxContainer.hide()


func on_button_pressed(button_name: String):
	match button_name:
		"BtnPokedex":
			if not pokedex.visible:
				pokedex.update_pokedex_progress("Kanto")
				pokedex.visible = true
		
		"BtnBank":
			if not pokemon_bank.visible:
				pokemon_bank.visible = true
		
		"BtnAchievements":
			if not achievements.visible:
				achievements.visible = true
				
		"BtnQuests":
			if QuestUpdate.active_quests.size() == 3:
				return
				
			if not quest_panel.visible:
				if quest_panel.available_quests.size() == 0:
					for j in range(3):
						quest_panel.generate_quest()
						
					quest_panel.update_quest_info()
				
				quest_panel.visible = true
				
		"BtnShop":
			if not pokemon_shop.visible:
				pokemon_shop.visible = true
				
		"BtnCompanion":
			if data.companion.size() == 0:
				return
				
			if not companion.visible:
				companion.visible = true


func on_mouse_entered(slot: Control) -> void:
	party_slot_can_click = true
	target_slot = slot
	

func on_mouse_exited(_slot: Control) -> void:
	party_slot_can_click = false


func _on_remove_party_pressed() -> void:
	target_slot.sprite.texture = null
	target_slot.pokemon_info.clear()
	target_slot.get_node("Background/LevelLabel").text = ""
	
	SQL.db.query(
		"UPDATE banco_pokemon SET in_party = 0 WHERE id_pokemon = " + str(target_slot.id_pokemon)
	)
	
	get_tree().call_group("slot_bank", "update_on_companion", target_slot.id_pokemon, "remove")
	target_slot.id_pokemon = 0
