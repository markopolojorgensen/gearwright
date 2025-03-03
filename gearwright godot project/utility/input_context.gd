class_name InputContext
extends RefCounted

#var ic := InputContext.new()
#ic.id = input_context_system.INPUT_CONTEXT.BASE_ACTOR_BUILDER
#ic.activate = func(_is_stack_growing: bool):
	#pass
#ic.deactivate = func(_is_stack_growing: bool):
	#pass
#ic.handle_input = func(_event: InputEvent):
	#pass

var id: int = -1
var activated := false

var activate: Callable = func(_is_stack_growing: bool):
	activated = true

var deactivate: Callable = func(_is_stack_growing: bool):
	activated = false

var handle_input: Callable = func(_event: InputEvent):
	pass


