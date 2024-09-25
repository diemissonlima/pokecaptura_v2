extends Node

var quest_manager: QuestManager


func start_new_quest(name: String, description: String, value: int) -> void:
	quest_manager = QuestManager.new()
	
	var quest = Quest.new()
	quest.quest_name = name
	quest.description = description
	quest.goal = value
	
	quest_manager.add_quest(quest)


func generate_quest() -> void: # essa funcao vai ser chamada na tela de aceitar quest
	pass
	# start_new_quest()


func on_item_collected(quest_name: String) -> void:
	quest_manager.update_quest_progress(quest_name, 1)
