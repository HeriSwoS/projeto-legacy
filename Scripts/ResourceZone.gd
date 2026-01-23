extends Control

@onready var count_label = $CountLabel
var resource_count = 0

func update_count():
	if has_node("ResourceContainer"):
		resource_count = $ResourceContainer.get_child_count()
		if count_label:
			count_label.text = str(resource_count)
