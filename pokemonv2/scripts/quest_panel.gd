extends Control

@export_category("Objetos")
@export var quest_name_1: Label
@export var quest_description_1: Label
@export var quest_name_2: Label
@export var quest_description_2: Label
@export var quest_name_3: Label
@export var quest_description_3: Label

var available_quests: Array = []


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_quest_panel"):
		button.pressed.connect(on_button_pressed.bind(button))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quest_panel"):
		visible = not visible
		if available_quests.size() == 0:
			for j in range(3):
				generate_quest()
		
			update_quest_info()


func generate_quest() -> void:
	SQL.db.query(
		"SELECT COUNT(*) FROM quests"
	)
	
	var quest_id: int = SQL.db.query_result[0]["COUNT(*)"]
	
	var aux_available_quests: Dictionary = {}
	var name_list: Dictionary = {
		"normal": [
			"Desafio Comum", "Força da Simplicidade", "Mestres da Normalidade"
		],
		"fire": [
			"Chama da Vitória", "Caçador de Feras Ardentes", "Domador das Chamas"
		],
		"water": [
			"Maré Crescente", "Expedição Submersa", "Guardião das Águas"
		],
		"grass": [
			"Floresta Viva", "Herói da Natureza", "Segredos da Selva"
		],
		"electric": [
			"Força Relâmpago", "Sede de Poder", "Maestro da Tempestade"
		],
		"ice": [
			"Frio Cortante", "Gelo Eterno", "Explorador Ártico"
		],
		"fighting": [
			"Caminho do Guerreiro", "Força Implacável", "Desafio dos Mestres"
		],
		"poison": [
			"Veneno Letal", "Sombras Tóxicas", "Toque Mortal"
		],
		"ground": [
			"Guardiões da Terra", "Força Subterrânea", "Defensores do Solo"
		],
		"flying": [
			"Asas da Liberadade", "Caçador dos Céus", "Ventania Selvagem"
		],
		"psychic": [
			"Poderes Ocultos", "Mente Brilhante", "Visões do Futuro"
		],
		"bug": [
			"Exército de Carapaças", "Revolta dos Insetos", "Domador de Enxames"
		],
		"rock": [
			"Montanhas Indomáveis", "Coração de Pedra", "Resistência de Granito"
		],
		"ghost": [
			"Assombrações do Além", "Caminho dos Espectros", "Caça Fantasmas"
		],
		"dragon": [
			"Rastros Dracônicos", "Despertar do Dragão", "Fúria Dracônica"
		],
		"dark": [
			"Senhor das Sombras", "Caçador Noturno", "Lorde da Escuridão"
		],
		"steel": [
			"Coração de Ferro", "Metal Inquebrável", "Titãs de Aço"
		],
		"fairy": [
			"Magia Encantada", "Luz Brilhante", "Fábulas Encantadas"
		]
	}
	
	var type_list: Array = [
		"normal", "fire", "water", "grass", "electric", "ice", "fighting",
		"poison", "ground", "flying", "psychic", "bug", "rock", "ghost",
		"dragon", "dark", "steel", "fairy"
	]
	
	var type: String = type_list.pick_random()
	
	var quest_name = name_list[type].pick_random()
	var quest_objective = randi_range(2, 5)
	var quest_type = type
	
	var quest_description: String = "Capture " + str(quest_objective) + " Pokémon do tipo " + quest_type.capitalize()
	
	quest_id += 1
	aux_available_quests["id"] = quest_id
	aux_available_quests["name"] = quest_name
	aux_available_quests["description"] = quest_description
	aux_available_quests["progress"] = 0
	aux_available_quests["objective"] = quest_objective
	aux_available_quests["type"] = quest_type
	
	available_quests.append(aux_available_quests)


func update_quest_info() -> void:
	quest_name_1.text = "- " + available_quests[0]["name"]
	quest_description_1.text = available_quests[0]["description"]

	quest_name_2.text = "- " + available_quests[1]["name"]
	quest_description_2.text = available_quests[1]["description"]

	quest_name_3.text = "- " + available_quests[2]["name"]
	quest_description_3.text = available_quests[2]["description"]


func on_button_pressed(button: Button) -> void:
	if QuestUpdate.active_quests.size() == 3:
		return
		
	match button.name:
		"AcceptQuest1":
			QuestUpdate.active_quests.append(available_quests[0])
			SQL.quest_management(available_quests[0], "add")
			
		"AcceptQuest2":
			QuestUpdate.active_quests.append(available_quests[1])
			SQL.quest_management(available_quests[1], "add")
			
		"AcceptQuest3":
			QuestUpdate.active_quests.append(available_quests[2])
			SQL.quest_management(available_quests[2], "add")
	
	available_quests.clear()
	visible = false
