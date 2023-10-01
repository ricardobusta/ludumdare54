extends Node

@export var item_config: Array[ItemConfig] = []

@export var item_view_prefab: ItemView = null

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
    if amount <= 0:
        if _inventory_view.has(id):
            # remove id view
            pass # TODO
        else:
            # nothing to do
            pass # TODO
    else:
        if _inventory_view.has(id):
            # update amount
            pass # TODO
        else:
            # add view with amount
            pass # TODO

