extends Node

class_name InventoryController

@export var item_config: Array[ItemConfig] = []

@export_category("View")
@export var item_view_prefab: Resource = null
@export var item_view_container: Control = null

class ItemConfigEntry:
    var texture: Texture2D

var _item_dict: Dictionary = {}

var _inventory_state: Dictionary = {}

var _inventory_view: Dictionary = {}

func _ready():
    for item in item_config:
        var entry = ItemConfigEntry.new()
        entry.texture = item.texture
        _item_dict[item.name] = entry

func add_item(id: String, amount: int):
    if not _inventory_state.has(id):
        _inventory_state[id] = 0

    _inventory_state[id] += amount
    _refresh_inventory_item(id)

func remove_item(id: String, amount: int):
    if not _inventory_state.has(id):
        _inventory_state[id] = 0
    else:
        _inventory_state[id] = max(_inventory_state[id] - amount, 0)
    _refresh_inventory_item(id)

func has_item(id: String):
    return _inventory_state.has(id) and _inventory_state[id] > 0

func _refresh_inventory_item(id: String):
    var amount = _inventory_state[id]
    var view: ItemView = _inventory_view[id] as ItemView if _inventory_view.has(id) else null
    if amount <= 0:
        if view:
            # remove id view
            view.queue_free()
            _inventory_view[id] = null
        else:
            # nothing to do
            pass
    else:
        if view:
            # update amount
            view.set_amount(amount)
        else:
            # add view with amount
            view = item_view_prefab.instantiate()
            _inventory_view[id] = view
            item_view_container.add_child(view)
            view.set_amount(amount)
            var entry: ItemConfigEntry = _item_dict[id]
            view.set_icon(entry.texture)
