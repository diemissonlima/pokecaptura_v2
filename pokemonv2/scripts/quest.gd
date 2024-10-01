extends Node  # Poderia ser um Node também, mas usando Resource podemos criar várias quests facilmente

class_name Quest

# Propriedades básicas da quest
@export var quest_name: String
@export var description: String
@export var is_complete: bool = false
@export var quest_type: String
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
	var amount: int
	var rewards_list: Array = [
		"Pokeball", "Greatball", "Ultraball", "Repeatball", "Heavyball", "Credito"
	]
	var reward = rewards_list.pick_random()

	if reward == "Credito":
		amount = goal * 150
		print("Recompensa: ", reward, " Quantidade: ", amount)
		
	else:
		amount = randi_range(2, 5)
		print("Recompensa: ", reward, " Quantidade: ", amount)
		
	SQL.update_database("inventario", reward, "increase", amount)
