extends Node  # Poderia ser um Node também, mas usando Resource podemos criar várias quests facilmente

class_name Quest

# Propriedades básicas da quest
@export var quest_name: String
@export var description: String
@export var is_complete: bool = false
@export var goal: int = 0  # Número de itens ou ações necessárias para completar a quest
@export var progress: int = 0  # Progresso atual da quest

# Método para adicionar progresso
func add_progress(amount: int) -> void:
	progress += amount
	if progress >= goal:
		complete_quest()

# Completar a quest
func complete_quest() -> void:
	if not is_complete:
		is_complete = true
		print("Quest completada: %s" % quest_name)
		_give_rewards()

# Método para dar a recompensa ao jogador
func _give_rewards() -> void:
	# Implementar lógica para dar recompensas (ex: itens, XP)
	print("Recompensas entregues para a quest: %s" % quest_name)
