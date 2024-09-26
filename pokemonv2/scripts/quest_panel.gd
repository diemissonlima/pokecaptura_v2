extends Control


@export_category("Objetos")
@export var quest_title: Label
@export var quest_name_label: Label
@export var quest_progress_label: Label
@export var quest_description_progress_label: Label
@export var quest_name_progress_label: Label

var quest_name: String
var quest_description: String
var quest_objective

var quest_progress: int = 0
var quest_reward_amount: int = 0
var quest_type: String = ""
var quest_reward: String = ""


func _ready() -> void:
	if QuestUpdate.active_quests.size() == 0:
		generate_quest()
	else:
		quest_name = QuestUpdate.active_quests[0].quest_name
		quest_description = QuestUpdate.active_quests[0].description
		quest_objective = QuestUpdate.active_quests[0].goal
		quest_progress = QuestUpdate.active_quests[0].progress
		
	quest_progress_label.text = str(quest_progress) + " / " + str(quest_objective)
	
	quest_name_progress_label.text = "- " + quest_name
	quest_description_progress_label.text = quest_description


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quest_panel"):
		visible = not visible
		if QuestUpdate.active_quests.size() == 1:
			$Background/QuestToAccept.hide()
			$Background/Quests.show()
		elif QuestUpdate.active_quests.size() == 0:
			$Background/QuestToAccept.show()
			$Background/Quests.hide()


func generate_quest() -> void:
	var name_list: Dictionary = {
		"normal": [
			"Desafio Comum", "Força da Simplicidade", "Mestres da Normalidade"
		],
		"fire": [
			"Chama da Vitória", "Caçador de Feras Ardentes", "Domador das Chamas"
		],
		"water": [
			"Maré Crescente", "Expedição Submersa", "Guardião das Áduas"
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
			"Asas da Liberadade", "Caçados dos Céus", "Ventania Selvagem"
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
	
	quest_name = name_list[type].pick_random()
	
	quest_objective = randi_range(1, 5)
	quest_type = type
	
	quest_description = "Capture " + str(quest_objective) + " Pokémon do tipo " + quest_type.capitalize()
	
	update_quest_info()


func update_quest_info() -> void:
	quest_name_label.text = "- " + quest_name
	quest_title.text = quest_description


func update_quest_progress(value: int) -> void:
	quest_progress += value
	
	quest_progress_label.text = str(quest_progress) + " / " + str(quest_objective)


func _on_accetp_quest_pressed() -> void:
	QuestUpdate.start_new_quest(quest_name, quest_description, quest_objective, quest_type)
		
	$Background/QuestToAccept.hide()
	$Background/Quests.show()
