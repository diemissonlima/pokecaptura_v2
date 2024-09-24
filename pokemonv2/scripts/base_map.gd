extends Control
class_name BaseMap


@export_category("Objetos")
@export var spawn_position: Marker2D
@export var spawn_timer: Timer
@export var screen_capture: Control
@export var background: TextureRect
@export var options_container: HBoxContainer
@export var button_start_hunting: Button
@export var info: Label
@export var info2: Label

@export_category("Variaveis")
@export var pokemon_list: Array[PackedScene]
@export var pokemon_legendary_list: Array[PackedScene]
@export var path_background: String

var pokemon_spawned


func _ready() -> void:
	get_tree().call_group("screen_capture", "get_texture_path", path_background)
	spawn_legendary()


func spawn_legendary() -> void:
	var pokemon_legendary = pokemon_legendary_list.pick_random()
	pokemon_list.append(pokemon_legendary)


func spawn_pokemon() -> void:
	pokemon_spawned = pokemon_list.pick_random().instantiate()
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
			
	get_tree().call_group("pokedex_info", "show_pokemon", pokemon_spawned.id_dex, "visto")
