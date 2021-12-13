extends Reference

class_name GDUtil

enum {
	COMPONENT_DATA = 1
}


static func is_valid_type(instance : Object) -> bool:
	return instance.has_meta("value_type")


static func valid_type(instance : Object, type : int) -> bool:
	return is_valid_type(instance) and (get_type(instance) == type)


static func get_type(instance : Object) -> int:
	assert(is_valid_type(instance), "Instance is not a valid type")
	return instance.get_meta("value_type")
	
	
static func get_scene_dir() -> String:
	return "res://addons/GDEditor/Scenes/"
	
	
static func get_attachment_dir() -> String:
	return "res://addons/GDEditor/Scenes/Components/Attachments/"
	

static func array_swap_elementidx(arr : Array, from_idx : int, to_idx : int) -> void:
	var temp = arr[from_idx]
	arr[from_idx] = arr[to_idx]
	arr[to_idx] = temp
