extends Control
class_name MapManagement

#var pokemon_list: Array = [{
	#'001': {'id': '001', 'nome': 'Bulbasaur', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'002': {'id': '002', 'nome': 'Ivysaur', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'003': {'id': '003', 'nome': 'Venusaur', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'004': {'id': '004', 'nome': 'Charmander', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'005': {'id': '005', 'nome': 'Charmeleon', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'006': {'id': '006', 'nome': 'Charizard', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'007': {'id': '007', 'nome': 'Squirtle', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'008': {'id': '008', 'nome': 'Wartortle', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'009': {'id': '009', 'nome': 'Blastoise', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'010': {'id': '010', 'nome': 'Caterpie', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'011': {'id': '001', 'nome': 'Metadpod', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'012': {'id': '002', 'nome': 'Butterfree', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'013': {'id': '003', 'nome': 'Weedle', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'014': {'id': '004', 'nome': 'Kakuna', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'015': {'id': '005', 'nome': 'Beedrill', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'016': {'id': '006', 'nome': 'Pidgey', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'017': {'id': '007', 'nome': 'Pidgeotto', 'chance_a': 61, 'chance_b': 90, 'count': 0},
	#'018': {'id': '008', 'nome': 'Pidgeot', 'chance_a': 91, 'chance_b': 100, 'count': 0},
	#'019': {'id': '009', 'nome': 'Rattata', 'chance_a': 1, 'chance_b': 60, 'count': 0},
	#'020': {'id': '010', 'nome': 'Raticate', 'chance_a': 61, 'chance_b': 100, 'count': 0}
#}]

var aux_list: Array = []


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_map"):
		button.pressed.connect(on_button_pressed.bind(button.name))
	
	#pokemon()


#func pokemon() -> void:
	#var poke_list: Array = []
#
	#for i in range(100):
		#var random_number: int = randi() % 100 + 1
		#
		#for poke in pokemon_list:
			#for j in poke.values():
				#if random_number >= j["chance_a"] and random_number <= j["chance_b"]:
					#aux_list.append(j)
#
		#var pokemon_spawned = aux_list.pick_random()
		#
		#poke_list.append(pokemon_spawned)
		#aux_list.clear()
	#
	#var pokemon_count: Dictionary = {}
	#
	#for pokemon in poke_list:
		#var nome = pokemon["nome"]
		#
		#if nome in pokemon_count:
			#pokemon_count[nome] += 1
		#else:
			#pokemon_count[nome] = 1
			#
	#var sorted_pokemon = pokemon_count.keys()
	#sorted_pokemon.sort_custom(func(a, b):
		#return int(pokemon_count[b] - pokemon_count[a])
		#)
	#for nome in sorted_pokemon:
		#print(nome, " aparece ", pokemon_count[nome], " vezes")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_map"):
		visible = not visible


func on_button_pressed(button_name: String) -> void:
	var new_map: String = "res://scenes/map_management/" + button_name.to_lower() + ".tscn"
	
	transition_manager.fade_to_scene(new_map)
