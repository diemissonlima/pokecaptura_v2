extends Node

class_name QuestManager

# Lista de quests do jogador
var active_quests: Array = []

# Adicionar uma nova quest
func add_quest(quest: Quest) -> void:
	if quest not in active_quests:
		active_quests.append(quest)
		print("Quest adicionada: %s" % quest.quest_name)

# Remover uma quest quando completa
func remove_quest(quest: Quest) -> void:
	if quest in active_quests:
		active_quests.erase(quest)
		print("Quest removida: %s" % quest.quest_name)

# Atualizar progresso de uma quest específica
func update_quest_progress(quest_name: String, amount: int) -> void:
	print("Item da quest ", quest_name, " coletado")
	for quest in active_quests:
		if quest.quest_name == quest_name:
			quest.add_progress(amount)
			if quest.is_complete:
				remove_quest(quest)
