extends Node

var quest_manager: QuestManager
# ao trocar de cena a quest é perdida e aparece pra selecionar uma nova

var active_quests: Array = []


func notify_quest_rewards(quest_info: Array) -> void:
	get_tree().call_group("screen_capture", "show_quest_rewards", quest_info)
	
	quest_is_complete()


func start_new_quest(
	name: String, description: String, objective, quest_type: String) -> void:
		
	quest_manager = QuestManager.new()
	
	var quest = Quest.new()
	quest.quest_name = name
	quest.description = description
	quest.goal = objective
	quest.quest_type = quest_type
	
	quest_manager.add_quest(quest)


func on_item_collected(quest_name: String) -> void:
	quest_manager.update_quest_progress(quest_name, 1)

	get_tree().call_group("quest_panel", "update_quest_progress", 1)


func quest_is_complete() -> void:
	if active_quests.size() == 0:
		get_tree().call_group("quest_panel", "generate_quest")
