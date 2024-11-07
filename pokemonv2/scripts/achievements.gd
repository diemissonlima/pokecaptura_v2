extends Control

@export_category("Objetos")
@export var type_container: GridContainer


var achievement_level_dict: Dictionary = {
	"1": 5, "2": 10, "3": 15, "4": 20, "5": 25,
	"6": 30, "7": 35, "8": 40, "9": 45, "10": 50,
	"11": 55, "12": 60, "13": 65, "14": 70, "15": 75,
	"16": 80, "17": 85, "18": 90, "19": 95, "20": 100
}


func _ready() -> void:
	for type in type_container.get_children():
		var achievement_info = SQL.verify_achievement(type.name)
		
		var progress_bar = type.get_node("ProgressBar")
		var progress_bar_label = progress_bar.get_node("Label")
		var level_label = progress_bar.get_node("Label2")
		
		progress_bar.max_value = achievement_level_dict[str(achievement_info[1])]
		progress_bar.value = achievement_info[0]
		
		progress_bar_label.text = str(achievement_info[0]) + " / " + str(achievement_level_dict[str(achievement_info[1])])
		level_label.text = "Nivel " + str(achievement_info[1])


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit") and visible:
		visible = false


func update_achievement(type: String) -> void:
	for j in type_container.get_children():
		if type == j.name:
			var progress_bar = j.get_node("ProgressBar")
			var progress_bar_label = progress_bar.get_node("Label")
			var level_label = progress_bar.get_node("Label2")
			var achievement_info = SQL.verify_achievement(type)
			
			var amount = achievement_info[0]
			var current_level = achievement_info[1]
			
			amount += 1
			progress_bar.value = amount
			
			SQL.update_achievement(type, "amount", amount)
			
			if amount == achievement_level_dict[str(current_level)]:
				current_level += 1
				progress_bar.value = 0
				progress_bar.max_value = achievement_level_dict[str(current_level)]
				
				achievement_level_up(type, current_level)
			
			progress_bar_label.text = str(progress_bar.value) + " / " + str(achievement_level_dict[str(current_level)])
			level_label.text = "Nivel " + str(current_level)
			
			
func achievement_level_up(type: String, current_level: int) -> void:
	SQL.update_achievement(type, "current_level", current_level)
	SQL.update_achievement(type, "amount", 0)
	
	var rewards: Array = give_rewards()
	
	get_tree().call_group("screen_capture", "notify_achievement_levelup", type, rewards)


func give_rewards() -> Array:
	var rewards: Array = []
	var random_number: int = randi_range(1, 100)
	var possible_rewards: Dictionary = {
		"item_1": {"name": "Pokeball", "probability": [1, 40], "amount": [1, 5]},
		"item_2": {"name": "Greatball", "probability": [41, 70], "amount": [1, 5]},
		"item_3": {"name": "Ultraball", "probability": [71, 80], "amount": [1, 5]},
		"item_4": {"name": "Repeatball", "probability": [81, 90], "amount": [1, 5]},
		"item_5": {"name": "Heavyball", "probability": [91, 99], "amount": [1, 5]},
		"item_6": {"name": "Masterball", "probability": [100, 100], "amount": [1, 1]}
		}
		
	for item in possible_rewards.values():
		if random_number >= item["probability"][0] and random_number <= item["probability"][1]:
			var amount: int = randi_range(item["amount"][0], item["amount"][1])
			
			rewards.append([item["name"], amount])
	
	return rewards
