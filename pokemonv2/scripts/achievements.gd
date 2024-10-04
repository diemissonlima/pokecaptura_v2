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
				progress_bar.max_value = achievement_level_dict[str(current_level)]
				
				achievement_level_up(type, current_level)
			
			progress_bar_label.text = str(progress_bar.value) + " / " + str(achievement_level_dict[str(current_level)])


func achievement_level_up(type: String, current_level: int) -> void:
	SQL.update_achievement(type, "current_level", current_level)
	
	get_tree().call_group("screen_capture", "notify_achievement_levelup", type)
