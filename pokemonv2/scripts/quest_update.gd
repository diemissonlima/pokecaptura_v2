extends Node

var active_quests: Array = []


func _ready() -> void:
	load_quests_onready_scene()
	
	give_rewards("quest", 5)


func on_item_collected(type_1: String, type_2: String) -> void:
	for quest in active_quests:
		if type_1.to_lower() == quest["type"] or type_2.to_lower() == quest["type"]:
			quest["progress"] += 1
			SQL.quest_management(quest, "update_progress")
		
			if quest["progress"] == quest["objective"]:
				give_rewards(quest["name"], quest["objective"])
				SQL.quest_management(quest, "update_status")
				active_quests.erase(quest)


func give_rewards(quest_name: String, value: int) -> void:
	# Implementar lógica para dar recompensas (ex: itens, XP)
	var quest_rewards: Array = []
	
	var random_number: int = randi_range(1, 100)
	var possible_rewards: Dictionary = {
		"item_1": {"name": "Credito", "probability": [1, 30], "amount": [value * 150, value * 150]},
		"item_2": {"name": "Pokeball", "probability": [31, 50], "amount": [1, 5]},
		"item_3": {"name": "Greatball", "probability": [51, 70], "amount": [1, 5]},
		"item_4": {"name": "Ultraball", "probability": [71, 80], "amount": [1, 5]},
		"item_5": {"name": "Repeatball", "probability": [81, 90], "amount": [1, 5]},
		"item_6": {"name": "Heavyball", "probability": [91, 98], "amount": [1, 5]},
		"item_7": {"name": "Masterball", "probability": [99, 100], "amount": [1, 1]}
		}
	
	for item in possible_rewards.values():
		if random_number >= item["probability"][0] and random_number <= item["probability"][1]:
			var amount: int = randi_range(item["amount"][0], item["amount"][1])
			
			quest_rewards.append([quest_name, item["name"], amount])
	
			SQL.update_database("inventario", item["name"], "increase", amount)
	
	get_tree().call_group("screen_capture", "show_quest_rewards", quest_rewards)


func load_quests_onready_scene() -> void:
	SQL.db.query(
		"SELECT * FROM quests WHERE status = 'in_progress'"
	)
	
	var quest_list: Array = SQL.db.query_result 
	if quest_list.is_empty():
		return
		
	active_quests = quest_list.duplicate()
