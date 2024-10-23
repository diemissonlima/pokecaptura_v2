extends CharacterBody2D
class_name PokemonBase

@export_category("Variaveis")
@export var id_dex: String
@export var pokemon_name: String
@export_enum(
	"Bug", "Dark", "Dragon", "Electric", "Fairy", "Fighting", "Fire", "Flying", "Ghost", 
	"Grass", "Ground", "Ice", "Normal", "Poison", "Psychic", "Rock", "Steel", "Water"
) var primary_type: String
@export_enum(
	"Bug", "Dark", "Dragon", "Electric", "Fairy", "Fighting", "Fire", "Flying", "Ghost", 
	"Grass", "Ground", "Ice", "Normal", "Poison", "Psychic", "Rock", "Steel", "Water"
) var secondary_type: String
@export_enum("Basico", "Estagio 1", "Estagio 2") var estagio: String
@export_enum(
	"Kanto", "Johto", "Hoenn", "Sinnoh", "Unova", "Kalos", "Alola", "Galar"
) var region: String
@export var nature: String
@export var ability: Dictionary
@export var evolution: String
@export var legendary: bool
@export var shiny: bool
@export var exp_base: int
@export var catch_rate: float
@export var weight: float

@export_category("Objetos")
@export var animated_sprite: AnimatedSprite2D
@export var info_catch: Sprite2D
@export var type_1: Sprite2D
@export var type_2: Sprite2D
@export var is_shiny_label: Label

var nature_description: String
var dropped_credit: int


func _ready() -> void:
	get_nature()
	is_shiny()
	alter_characteristics()
	
	animated_sprite.speed_scale = 6
	
	if SQL.verify_pokemon_captured(id_dex) == 2:
		info_catch.modulate.a = 1.0


func get_nature() -> void:
	var nature_list: Array = [
	"Hardy", "Bold", "Modest", "Calm", "Timid", "Lonely", "Docile", "Mild", "Gentle", 
	"Hasty", "Adamant", "Impish", "Bashful", "Careful", "Jolly", "Naughty", "Lax", 
	"Rash",  "Quirky", "Naive","Brave", "Relaxed", "Quiet", "Sassy", "Serious"
	]
	
	nature = nature_list.pick_random()


func is_shiny() -> void:
	var random_number: float = randf()
	var shiny_probability: float = 0.01
	
	if random_number <= shiny_probability:
		shiny = true
		animated_sprite.play("shiny")
		is_shiny_label.show()


func alter_characteristics() -> void:
	var multiplier: float
	
	match estagio:
		"Basico":
			multiplier = 1
			dropped_credit = randi_range(100, 150)
		
		"Estagio 1":
			multiplier = 1.5
			dropped_credit = randi_range(151, 200)
			
		"Estagio 2":
			multiplier = 2.0
			dropped_credit = randi_range(201, 250)
	
	if legendary:
		multiplier = 3
		dropped_credit = randi_range(251, 400)
	
	if shiny:
		catch_rate = catch_rate - (catch_rate * 25 / 100)
		exp_base = int(exp_base * 2 * multiplier)
		dropped_credit *= multiplier * 2
	else:
		exp_base = int(exp_base * multiplier)
		dropped_credit *= multiplier
	
	apply_modifier()
	
	get_ability()


func apply_modifier() -> void:
	var nature_list: Dictionary = {
		1: ['Timid', 'Modest', 'Relaxed', 'Hasty', 'Quirky'],
		2: ['Rash', 'Lax', 'Calm', 'Jolly', 'Adamant'],
		3: ['Careful', 'Serious', 'Impish', 'Sassy', 'Naive'],
		4: ['Lonely', 'Gentle', 'Brave', 'Hardy', 'Mild'],
		5: ['Bold', 'Docile', 'Naughty', 'Bashful', 'Quiet']
	}
	
	if nature in nature_list[1]: # aumenta catch rate em 20% e diminui drop de credito em 20%
		catch_rate = catch_rate + (catch_rate * 20 / 100)
		dropped_credit = dropped_credit - (dropped_credit * 20 / 100)
		nature_description = "Pokemon dessa natureza é 20% mais fácil de capturar e diminui em 20% o drop de Crédito no momento da captura."
		
	elif nature in nature_list[2]: # diminui catch rate em 20% e aumenta drop de credito em 20%
		catch_rate = catch_rate - (catch_rate * 20 / 100)
		dropped_credit = dropped_credit + (dropped_credit * 20 / 100)
		nature_description = "Pokemon dessa natureza é 20% mais difícil de capturar e aumenta em 20% o drop de Crédito no momento da captura."

	elif nature in nature_list[3]: # diminui catch rate em 10% e diminui drop de credito em 10%
		catch_rate = catch_rate - (catch_rate * 10 / 100)
		dropped_credit = dropped_credit - (dropped_credit * 10 / 100)
		nature_description = "Pokemon dessa natureza é 10% mais difícil de capturar e diminui em 10% o drop de Crédito no momento da captura."
		
	elif nature in nature_list[4]: # aumenta catch rate em 15% e aumenta drop de credito em 15%
		catch_rate = catch_rate + (catch_rate * 15 / 100)
		dropped_credit = dropped_credit + (dropped_credit * 15 / 100)
		nature_description = "Pokemon dessa natureza é 15% mais fácil de capturar e aumenta em 15% o drop de Crédito no momento da captura."

	elif nature in nature_list[5]: # nao muda nada
		nature_description = "Sem modificador de Natureza."
		return


func get_ability() -> void:
	var ability_list: Dictionary = {
		"Bargainer": {
			"description": "Reduz o preço das Pokébolas no Shop em 10%",
			"modifier": 0.1
		},
		
		"Steady Hand (Pokeball)": {
			"description": "Eficácia da Pokeball aumenta em 10%",
			"modifier": 0.1
		},
		
		"Steady Hand (Greatball)": {
			"description": "Eficácia da Greatball aumenta em 10%",
			"modifier": 0.1
		},
		
		"Steady Hand (Ultraball)": {
			"description": "Eficácia da Ultraball aumenta em 10%",
			"modifier": 0.1
		},
		
		"Fortune Finder": {
			"description": "Aumenta em 20% o drop de Créditos",
			"modifier": 0.2
		},
		
		"Elemental Mastery (Bug)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo BUG",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Dark)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo DARK",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Dragon)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo DRAGON",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Electric)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo ELECTRIC",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Fairy)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo FAIRY",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Fighting)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo FIGHTING",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Fire)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo FIRE",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Flying)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo FLYING",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Ghost)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo GHOST",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Grass)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo GRASS",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Ground)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo GROUND",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Ice)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo ICE",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Poison)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo POISON",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Psychic)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo PSYCHIC",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Rock)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo ROCK",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Steel)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo STEEL",
			"modifier": 0.15
		},
		
		"Elemental Mastery (Water)": {
			"description": "Aumenta em 15% a chance de captura de Pokémon do tipo WATER",
			"modifier": 0.15
		},
		
		"Pokéball Expert": {
			"description": "Aumenta a chance de captura em 10% se usar a mesma Pokébola após falhar",
			"modifier": 0.10
		},
		
		"Conservationist": {
			"description": "15% de chance de não gastar a Pokébola usada",
			"modifier": 0.15
		},
		
		"Resourceful": {
			"description": "5% de chance de receber uma Pokébola aleatória ao capturar um Pokémon",
			"modifier": 0.05
		},
		
		"Shiny Hunter": {
			"description": "Aumenta em 20% a chance de captura se o Pokémon for SHINY",
			"modifier": 0.2
		}
	}
	
	var ability_keys = ability_list.keys()
	var key = ability_keys.pick_random()
	
	ability["name"] = key
	ability["description"] = ability_list[key]["description"]
	ability["modifier"] = ability_list[key]["modifier"]
