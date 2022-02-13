extends GDDialogueReader

class_name GDPipeReader


class WaitManager extends Resource:
	func _init(obj: Object, signal_name: String, callback: FuncRef, args := []) -> void:
		yield_for(obj, signal_name, callback, args)
	
	static func yield_for(obj: Object, signal_name: String, callback: FuncRef, args := []) -> void:
		yield(obj, signal_name)
		
		callback.call_funcv(args)


class Awaitable extends Resource:
	signal finished
	
	var _finished := false
	var _data 
	
	func is_finished() -> bool:
		return _finished
	
	func get_data():
		if _finished:
			return _data
	
	func set_data(value) -> void:
		assert(not _finished)
		_data = value
		finish()
	
	func finish() -> void:
		_finished = true
		emit_signal("finished")


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GNPipe


func render(graph_node: GNPipe, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var node_connection := graph_node.get_connections()
	
	var awaitable := get_node_data(graph_node)
	
	if not awaitable.is_finished():
		yield(awaitable, "finished")
	
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			var evaluation : bool = awaitable.get_data()
			
			var flows := cursor.get_flows_right()
			
			var next_index := 0
			
			if evaluation:
				# Output true port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 0}])
				assert(next_index != -1, "%s Output port 0 has no connection" % [graph_node.name])
			else:
				# Output false port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 1}])
				assert(next_index != -1, "%s Output port 1 has no connection" % [graph_node.name])
			
			cursor.next(next_index)
		GNPipe.PipeType.WAIT_FOR:
			cursor.next()
		GNPipe.PipeType.WAIT_TILL:
			pass
		
	dialogue_viewer.next()


func get_node_data(graph_node: GNPipe) -> Awaitable:
	var awaitable := Awaitable.new()
	
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			var expression_edit : Control = graph_node.get_node("ExpressionEdit")
			var value : bool = expression_edit.get_value()
			awaitable.set_data(value)
			
		GNPipe.PipeType.WAIT_FOR:
			var wait_section : Control = graph_node.get_node("WaitSection")
			var callback := funcref(awaitable, "finish")
			WaitManager.yield_for(wait_section, "wait_finished", callback)
			wait_section.start()
			
		GNPipe.PipeType.WAIT_TILL:
			pass

	return awaitable
