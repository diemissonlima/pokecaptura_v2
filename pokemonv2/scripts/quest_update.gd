extends Node

var active_quests: Array = []


func on_item_collected(type_1: String, type_2: String) -> void:
	for quest in active_quests:
		if type_1.to_lower() == quest["type"] or type_2.to_lower() == quest["type"]:
			quest["progress"] += 1
		
			if quest["progress"] == quest["objective"]:
				give_rewards(quest["name"], quest["objective"])
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
