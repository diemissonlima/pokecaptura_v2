extends Control

@export_category("Obejtos")
@export var sprite: TextureRect = null

@export_category("Variaveis")
@export var id_pokemon: int

var pokemon_info: Dictionary


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit") and visible:
		visible = false
	
	set_info()


func set_info() -> void:
	if data.companion.size() != 0:
		$LevelContainer/LevelLabel.text = "Lvl " + str(data.companion["level"])
		$LevelContainer/NameLabel.text = data.companion["nome"]
		
		$TypeContainer/PrimaryType.texture = load("res://assets/prefabs/pokemon_type/" + data.companion["primary_type"].to_lower() + ".png")
	
		if data.companion["primary_type"] == data.companion["secondary_type"]: # caso seja atendida significa que o pokemon nao tem um tipo secundario
			$TypeContainer/SecondaryType.hide() # entao é ocultado 
		else:
			$TypeContainer/SecondaryType.show()
			$TypeContainer/SecondaryType.texture = load("res://assets/prefabs/pokemon_type/" + data.companion["secondary_type"].to_lower() + ".png")
		
		$InfoContainer/ID/IDContainer/IDLabel.text = "ID: " + str(data.companion["id_pokemon"])
		$InfoContainer/ID/IDContainer/DexLabel.text = "Dex: " + str(data.companion["numero_dex"])
		$InfoContainer/Nature/NatureLabel.text = "Nature: " + data.companion["nature"]
		$InfoContainer/Region/RegionLabel.text = "Region: " + data.companion["region"]
		$InfoContainer/Exp/ExpLabel.text = "Exp: " + str(data.companion["current_exp"]) + " / " + str(data.level_dict[str(data.companion["level"])])
		$Ability.text = "Habilidade: " + data.companion["ability"]
		$AbilityDescription.text = "Descrição: " + data.companion["ability_description"]
		$Pokeball.texture = load("res://assets/prefabs/pokeball/" + data.companion["pokeball"].to_lower() + ".png")


func _on_change_pet_pressed() -> void:
	sprite.texture = null
	data.companion.clear()
	
	SQL.db.query(
		"UPDATE banco_pokemon SET in_party = 0 WHERE id_pokemon = " + str(id_pokemon)
	)
	
	get_tree().call_group("slot_bank", "update_on_companion", id_pokemon, "remove")
	id_pokemon = 0
	
	visible = false
	
	await get_tree().create_timer(0.5).timeout
	get_tree().call_group("mapa", "on_button_pressed", "BtnBank")
