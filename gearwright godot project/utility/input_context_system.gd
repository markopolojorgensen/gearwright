extends Node

# key is INPUT_CONTEXT
# value is InputContext
var input_contexts := {}
var input_context_stack: Array[InputContext] = []
var is_input_context_accepting_input := true

enum INPUT_CONTEXT {
	MECH_BUILDER,
	MECH_BUILDER_CUSTOM_BACKGROUND,
	INVENTORY_SYSTEM_HOLDING_ITEM,
	INVENTORY_SYSTEM_UNLOCK,
	POPUP_ACTIVE,
	FISH_BUILDER,
	MECH_BUILDER_MANUAL_ADJUSTMENT,
	FISHER_PROFILE,
	PLAYER,
}

func register_input_context(input_context: InputContext):
	input_contexts[input_context.id] = input_context

func input_context_stack_handle_input(event: InputEvent):
	for i in range(input_context_stack.size() - 1):
		var context: InputContext = input_context_stack[i]
		assert(not context.activated)
	
	var current_context: InputContext = input_context_stack.back()
	if current_context == null:
		push_error("Input Context Stack is empty!")
		return
	assert(current_context.activated)
	
	if is_input_context_accepting_input:
		await current_context.handle_input.call(event)

func push_input_context(input_context: INPUT_CONTEXT):
	if not input_contexts.has(input_context):
		push_error("no InputContext for %s" % str(INPUT_CONTEXT.find_key(input_context)))
		return
	
	_deactivate_input_context(true)
	var new_context: InputContext = input_contexts[input_context] as InputContext
	input_context_stack.append(new_context)
	_activate_input_context(true)
	global_util.fancy_print("pushed input context: %s" % str(INPUT_CONTEXT.find_key(input_context)))
	global_util.indent()

func pop_input_context_stack():
	global_util.dedent()
	global_util.fancy_print("popped input context")
	_deactivate_input_context(false)
	input_context_stack.pop_back()
	_activate_input_context(false)

func pop_to(input_context: INPUT_CONTEXT):
	if get_current_input_context_id() == input_context:
		return
	elif input_context_stack.is_empty():
		return
	else:
		pop_input_context_stack()
		pop_to(input_context)

# doesn't pop anything off the stack, just yeets everything
func clear():
	input_context_stack.clear()
	global_util.clear_indentation()

func get_current_input_context_id() -> INPUT_CONTEXT:
	return input_context_stack.back().id

func get_current_input_context_name() -> String:
	return INPUT_CONTEXT.find_key(get_current_input_context_id())

func is_in_stack(input_context: INPUT_CONTEXT):
	return input_context in input_context_stack.map(func(ic: InputContext): return ic.id)



# always operates on back context
func _activate_input_context(is_stack_growing: bool):
	if not input_context_stack.is_empty():
		var back_context: InputContext = input_context_stack.back() as InputContext
		assert(not back_context.activated)
		#global_util.fancy_print("activating   %s" % str(back_context))
		back_context.activate.call(is_stack_growing)
		back_context.activated = true

# always operates on back context
func _deactivate_input_context(is_stack_growing: bool):
	if not input_context_stack.is_empty():
		var back_context: InputContext = input_context_stack.back() as InputContext
		assert(back_context.activated)
		#global_util.fancy_print("deactivating %s" % str(back_context))
		back_context.deactivate.call(is_stack_growing)
		back_context.activated = false

# you can disable this and do it yourself if there's some input events you
#  want to handle outside of this system
func _input(event: InputEvent) -> void:
	if input_context_stack.is_empty():
		return
	
	input_context_stack_handle_input(event)


