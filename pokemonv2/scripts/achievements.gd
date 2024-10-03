extends Control

@export_category("Objetos")
@export var type_container: GridContainer


var achievement_level_dict: Dictionary = {
	"1": 1, "2": 5, "3": 10, "4": 15, "5": 20
}

func _ready() -> void:
	update_achievement("Rock")


func update_achievement(type: String) -> void:
	for j in type_container.get_children():
		if type == j.name:
			var progress_bar = j.get_node("ProgressBar")
			var progress_bar_label = progress_bar.get_node("Label")
			
			progress_bar.value += 1
			progress_bar_label.text = str(progress_bar.value) + " / 1"
