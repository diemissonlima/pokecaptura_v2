extends Node

var db: SQLite


func _ready() -> void:
	create_database()
	#insert_data()


func create_database() -> void:
	var table_name: String
	var table_dict: Dictionary = {}
	
	db = SQLite.new()
	db.path = "res://database/poke_captura"
	db.open_db()
	
	table_name = "pokemon"
	table_dict["id"] = {"data_type": "text"}
	table_dict["nome"] = {"data_type": "text"}
	table_dict["visto"] = {"data_type": "int"}
	table_dict["capturado"] = {"data_type": "int"}
	table_dict["shiny_visto"] = {"data_type": "int"}
	table_dict["shiny_capturado"] = {"data_type": "int"}
	table_dict["status_pokedex"] = {"data_type": "int"}
	db.create_table(table_name, table_dict)
	table_dict.clear()
	
	table_name = "inventario"
	table_dict["id_item"] = {"data_type": "int"}
	table_dict["nome"] = {"data_type": "text"}
	table_dict["amount"] = {"data_type": "int"}
	table_dict["description"] = {"data_type": "text"}
	db.create_table(table_name, table_dict)


func insert_data() -> void:
	var row_array: Array = []
	var row_dict: Dictionary = {}
	var index: int = 252
	for poke in data.data_management.values():
		while index <= 386:
			
			if index <= 9:
				row_array.append(poke["00" + str(index)])
			if index >= 10 and index <= 99:
				row_array.append(poke["0" + str(index)])
			if index >= 100:
				row_array.append(poke[str(index)])
				
			index += 1
	
	for poke in row_array.size():
		row_dict["id"] = row_array[poke]["id"]
		row_dict["nome"] = row_array[poke]["nome"]
		row_dict["visto"] = row_array[poke]["visto"]
		row_dict["capturado"] = row_array[poke]["capturado"]
		row_dict["shiny_visto"] = row_array[poke]["shiny_visto"]
		row_dict["shiny_capturado"] = row_array[poke]["shiny_capturado"]
		row_dict["status_pokedex"] = row_array[poke]["status_pokedex"]
		
		db.insert_row("pokemon", row_dict)


func return_pokedex_progress() -> Array:
	var pokedex_progress: Array = []
	db.query(
		"SELECT COUNT(*) FROM pokemon WHERE status_pokedex > 0"
	)
	
	var amount_visto: int = db.query_result[0]["COUNT(*)"]
	pokedex_progress.append(amount_visto)
	
	db.query(
		"SELECT COUNT(DISTINCT numero_dex) FROM banco_pokemon"
	)
	
	var amount_capturado: int = db.query_result[0]["COUNT(DISTINCT numero_dex)"]
	pokedex_progress.append(amount_capturado)
	
	return pokedex_progress


func update_pokemon(id_pokemon: String, sql_column: String) -> void:
	var id = id_pokemon
	var column = sql_column

	var query = db.select_rows(
		"pokemon",
		"id = '" + id + "'",
		["*"]
	)
	
	var value: int = query[0][column]
	value += 1
	
	db.update_rows("pokemon", "id = '" + id + "'", {column: value})
		
	match column:
		"visto":
			if verify_pokemon_captured(id) == 2:
				return
			db.update_rows("pokemon", "id = '" + id + "'", {"status_pokedex": 1})
			
		"shiny_visto":
			if verify_pokemon_captured(id) == 2:
				return
			db.update_rows("pokemon", "id = '" + id + "'", {"status_pokedex": 1})
			
		"capturado":
			db.update_rows("pokemon", "id = '" + id + "'", {"status_pokedex": 2})
		
		"shiny_capturado":
			db.update_rows("pokemon", "id = '" + id + "'", {"status_pokedex": 2})


func update_database(table_name: String, item_used: String, type: String, value: int) -> void:
	var query = db.select_rows(
		table_name,
		"name = '" + item_used + "'",
		["*"]
	)
	
	var amount: int = query[0]["amount"]
	
	match type:
		"increase":
			amount += value
			
		"decrease":
			amount -= value
	
	db.update_rows(table_name, "name = '" + item_used + "'", {"amount": amount})


func verify_item_amount_on_inventory(item_name: String) -> int:
	var query = db.select_rows(
		"inventario",
		"name = '" + item_name + "'",
		["*"]
	)
	
	var amount: int = query[0]["amount"]
	
	return amount


func verify_pokemon_captured(id: String) -> int:
	var query = db.select_rows(
		"pokemon",
		"id = '" + id + "'",
		["*"]
	)
	
	if query[0]["status_pokedex"] == 1:
		return 1
	elif query[0]["status_pokedex"] == 2:
		return 2
	
	return 0


func verify_statistics(item_name: String) -> int:
	var query = db.select_rows(
		"estatisticas",
		"name = '" + item_name + "'",
		["*"]
	)
	
	var amount: int = query[0]["amount"]
	
	return amount


func info_pokedex(id: String) -> Dictionary:
	var query = db.select_rows(
		"pokemon",
		"id = '" + id + "'",
		["*"]
	)
	var pokemon_info = query[0]
	
	return pokemon_info


func add_pokemon_to_bank(pokemon: CharacterBody2D):
	var current_time = Time.get_datetime_dict_from_system()
	var formatted_date = "%02d/%02d/%04d" % [current_time.day, current_time.month, current_time.year]
	var formatted_time = "%02d:%02d:%02d" % [current_time.hour, current_time.minute, current_time.second]

	var row_array: Array = []
	var row_dict: Dictionary = {}
	
	if pokemon.secondary_type == "":
		pokemon.secondary_type = pokemon.primary_type
		
	row_array.append(formatted_date)
	row_dict["data_captura"] = row_array[0]
	
	row_array.append(formatted_time)
	row_dict["hora_captura"] = row_array[1]
	
	row_array.append(pokemon.id_dex)
	row_dict["numero_dex"] = row_array[2]
	
	row_array.append(pokemon.pokemon_name)
	row_dict["nome"] = row_array[3]
	
	row_array.append(pokemon.primary_type)
	row_dict["primary_type"] = row_array[4]
	
	row_array.append(pokemon.secondary_type)
	row_dict["secondary_type"] = row_array[5]
	
	row_array.append(pokemon.region)
	row_dict["region"] = row_array[6]
	
	row_array.append(pokemon.nature)
	row_dict["nature"] = row_array[7]
	
	row_array.append(pokemon.legendary)
	row_dict["legendary"] = row_array[8]
	
	row_array.append(pokemon.shiny)
	row_dict["shiny"] = row_array[9]
	
	db.insert_row("banco_pokemon", row_dict)
