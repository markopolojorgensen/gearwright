extends GridContainer

signal spawn_item(item_ID)

func on_item_selected(a_Item_ID):
	spawn_item.emit(a_Item_ID)
