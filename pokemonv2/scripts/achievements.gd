extends Control

@export_category("Objetos")
@export var type_container: GridContainer


var achievement_level_dict: Dictionary = {
	"1": 1, "2": 5, "3": 10, "4": 15, "5": 20
}


func _ready() -> void:
	for type in type_container.get_children():
		var achievement_info = SQL.verify_achievement(type.name)
		
		var progress_bar = type.get_node("ProgressBar")
		var progress_bar_label = progress_bar.get_node("Label")
		
		progress_bar.max_value = achievement_level_dict[str(achievement_info[1])]
		progress_bar.value = achievement_info[0]
		
		progress_bar_label.text = str(achievement_info[0]) + " / " + str(achievement_level_dict[str(achievement_info[1])])


func update_achievement(type: String) -> void:
	for j in type_container.get_children():
		if type == j.name:
			var progress_bar = j.get_node("ProgressBar")
			var progress_bar_label = progress_bar.get_node("Label")
			var achievement_info = SQL.verify_achievement(type)
			
			achievement_info[0] += 1
			progress_bar.value = achievement_info[0]
			
			if achievement_info[0] == achievement_level_dict[str(achievement_info[1])]:
				achievement_level_up()
				print("Aumentar o nivel da conquista")
			
			progress_bar_label.text = str(progress_bar.value) + " / " + str(achievement_level_dict[str(achievement_info[1])])


func achievement_level_up() -> void:
	#update database
	pass
