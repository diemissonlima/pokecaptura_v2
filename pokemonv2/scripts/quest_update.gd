extends Node

var active_quests: Array = []


func _ready() -> void:
	load_quests_onready_scene()


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
	var quest_info: Array = []
	var amount: int
	var rewards_list: Array = [
		"Pokeball", "Greatball", "Ultraball", "Repeatball", "Heavyball", "Credito"
	]
	var reward = rewards_list.pick_random()

	if reward == "Credito":
		amount = value * 150
		
	else:
		amount = randi_range(2, 5)
		
	SQL.update_database("inventario", reward, "increase", amount)
	
	quest_info.append([quest_name, reward, amount])
	
	get_tree().call_group("screen_capture", "show_quest_rewards", quest_info)


func load_quests_onready_scene() -> void:
	SQL.db.query(
		"SELECT * FROM quests WHERE status = 'in_progress'"
	)
	
	var quest_list: Array = SQL.db.query_result 
	if quest_list.is_empty():
		return
		
	active_quests = quest_list.duplicate()
