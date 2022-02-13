tool

extends GDGraphNode

class_name GDChoiceGN

export(String) var s_choice_main
export(PoolStringArray) var s_choice_extras

var _original_height := rect_size.y


func _ready() -> void:
	$MainChoice/LineEdit.text = s_choice_main
	
	for choice in s_choice_extras:
		_add_choice(choice)


func get_component_name() -> String:
	return "Choice"


func _choice_size() -> int:
	var acc := 0
	
	for child in get_children():
		if child.filename == GDUtil.resolve("ChoiceEditRect.tscn"):
			acc += 1
			
	return acc


func _choice_index(choice_node : Control):
	var acc := 0
	
	for child in get_children():
		if child == choice_node:
			break
		
		if child.filename == GDUtil.resolve("ChoiceEditRect.tscn"):
			acc += 1
		
	# -1 to not count main_choice
	return acc - 1


func _add_choice(value := "") -> void:
	var flowport : HBoxContainer = load(GDUtil.resolve("ChoiceFlowPort.tscn")).instance()
	var edits : MarginContainer = load(GDUtil.resolve("ChoiceEditRect.tscn")).instance()
	
	flowport.connect("remove_choice", self, "_remove_choice_edit", [flowport, edits], CONNECT_ONESHOT)
	flowport.connect("tree_exited", self, "_readjust_rect_size", [], CONNECT_ONESHOT)
	
	edits.get_node("LineEdit").connect("text_changed", 
			self, "_on_choice_edit_text_changed", [edits])
	
	var bottom_margin : int = get_node("MainChoice").get_constant("margin_top")
	
	find_node("AddChoice").connect("pressed", edits, "add_constant_override", ["margin_bottom", bottom_margin])
	get_node("MainChoice").add_constant_override("margin_bottom", bottom_margin)
	
	add_child(flowport)
	add_child(edits)
	
	s_choice_extras.append(value)


func _on_AddChoice_pressed() -> void:
	_add_choice()
	
	
func _remove_choice_edit(flowport: Control, choice_edit: Control) -> void:
	s_choice_extras.remove(_choice_index(choice_edit))

	# They have to be freed in this order	
	choice_edit.queue_free()
	flowport.queue_free()


func _readjust_rect_size() -> void:
	# Reset last choice edit bottom margin
	get_child(get_child_count()-1).add_constant_override("margin_bottom", 0)

	# This is a fix to readjust the node's height after
	# deleting a choice container.
	rect_size.y = _original_height


func _on_MainChoiceEdit_text_changed(new_text: String) -> void:
	s_choice_main = new_text


func _on_choice_edit_text_changed(new_text: String, choice_edit : Control)  -> void:
	s_choice_extras[_choice_index(choice_edit)] = new_text