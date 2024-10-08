extends Control

@export_category("Objetos")
@export var type_container: GridContainer


var achievement_level_dict: Dictionary = {
	"1": 5, "2": 7, "3": 9, "4": 12, "5": 15,
	"6": 18, "7": 21, "8": 24, "9": 27, "10": 30,
	"11": 33, "12": 35, "13": 38, "14": 41, "15": 43,
	"16": 45, "17": 48, "18": 51, "19": 54, "20": 57
}


func _ready() -> void:
	for type in type_container.get_children():
		var achievement_info = SQL.verify_achievement(type.name)
		
		var progress_bar = type.get_node("ProgressBar")
		var progress_bar_label = progress_bar.get_node("Label")
		
		progress_bar.max_value = achievement_level_dict[str(achievement_info[1])]
		progress_bar.value = achievement_info[0]
		
		progress_bar_label.text = str(achievement_info[0]) + " / " + str(achievement_level_dict[str(achievement_info[1])])


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("achievement"):
		visible = not visible


func update_achievement(type: String) -> void:
	for j in type_container.get_children():
		if type == j.name:
			var progress_bar = j.get_node("ProgressBar")
			var progress_bar_label = progress_bar.get_node("Label")
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


func achievement_level_up(type: String, current_level: int) -> void:
	SQL.update_achievement(type, "current_level", current_level)
	SQL.update_achievement(type, "amount", 0)
	
	var rewards: Array = give_rewards(current_level)
	
	get_tree().call_group("screen_capture", "notify_achievement_levelup", type, rewards)


func give_rewards(current_level: int) -> Array:
	var possible_rewards: Dictionary = {
		"2": ["Pokeball", [2, 5]],
		"3": ["Greatball", [2, 5]],
		"4": ["Ultraball", [2, 5]],
		"5": ["Repeatball", [2, 5]],
		"6": ["Heavyball", [2, 5]],
		"7": ["Masterball", [1, 1]]
	}

	var dict_key: String = str(current_level)
	var reward_list: Array = possible_rewards[dict_key]
	
	var reward_item_name: String = reward_list[0]
	var reward_item_amount: int = randi_range(reward_list[1][0], reward_list[1][1])
	
	var rewards: Array = []
	
	rewards.append(reward_item_name)
	rewards.append(reward_item_amount)

	return rewards
