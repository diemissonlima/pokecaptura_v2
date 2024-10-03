extends Node

class_name QuestManager

# Adicionar uma nova quest
func add_quest(quest: Quest) -> void:
	if quest not in QuestUpdate.active_quests:
		QuestUpdate.active_quests.append(quest)


# Remover uma quest quando completa
func remove_quest(quest: Quest) -> void:
	if quest in QuestUpdate.active_quests:
		QuestUpdate.active_quests.erase(quest)


# Atualizar progresso de uma quest específica
func update_quest_progress(quest_name: String, amount: int) -> void:
	for quest in QuestUpdate.active_quests:
		if quest.quest_name == quest_name:
			quest.add_progress(amount)
			if quest.is_complete:
				remove_quest(quest)
