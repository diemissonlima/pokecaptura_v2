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
