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
@export var exp_base: int
@export var catch_rate: float
@export var weight: float
@export var nature: String
@export var ability: Dictionary
@export var legendary: bool
@export var shiny: bool

@export_category("Objetos")
@export var animated_sprite: AnimatedSprite2D
@export var info_catch: Sprite2D
@export var type_1: Sprite2D
@export var type_2: Sprite2D
@export var is_shiny_label: Label

var nature_description: String
var dropped_credit: int
var pokeball_used: String


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
	
	if data.companion.has("ability"):
		if data.companion["ability"] == "Shiny Hunter":
			shiny_probability += data.companion["ability_modifier"]
	
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
	var ability_list: Array = [
		"Bargainer", "Steady Hand (Pokeball)", "Steady Hand (Greatball)",
		"Steady Hand (Ultraball)", "Fortune Finder", "Synchronize",
		"Pokéball Expert", "Conservationist", "Resourceful", "Shiny Hunter"
	]
	
	var ability_name = ability_list.pick_random()
	var modificador: float = randf_range(0.01, 0.05)
	var modificador_arredondado = round(modificador * 100) / 100.0
	var modificador_percent = modificador_arredondado * 100
	
	ability["name"] = ability_name
	ability["modifier"] = modificador_arredondado
	
	match ability["name"]:
		"Bargainer":
			ability["description"] = "Reduz o preço das Pokébolas no Shop em " + str(modificador_percent) + "%"
		
		"Steady Hand (Pokeball)":
			ability["description"] = "Chance de captura usando Pokeball aumenta em " + str(modificador_percent) + "%"
		
		"Steady Hand (Greatball)":
			ability["description"] = "Chance de captura usando Greatball aumenta em " + str(modificador_percent) + "%"
		
		"Steady Hand (Ultraball)":
			ability["description"] = "Chance de captura usando Ultraball aumenta em " + str(modificador_percent) + "%"

		"Fortune Finder":
			ability["description"] = "Aumenta em " + str(modificador_percent) + "% o drop de Créditos"
			
		"Synchronize":
			ability["description"] = "+" + str(modificador_percent) + "% de captura se o Pokémon tiver o mesmo tipo"
			
		"Pokéball Expert":
			ability["description"] = "+" + str(modificador_percent) + "% de captura se usar a mesma Pokébola após falhar"
		
		"Conservationist":
			ability["description"] = str(modificador_percent) + "% de chance de não gastar a Pokébola usada"
		
		"Resourceful":
			ability["description"] = str(modificador_percent) + "% de chance de receber uma Pokébola aleatória ao capturar um Pokémon"
		
		"Shiny Hunter":
			ability["description"] = "Aumenta em " + str(modificador_percent) + "% a chance de o Pokémon selvagem ser SHINY"
