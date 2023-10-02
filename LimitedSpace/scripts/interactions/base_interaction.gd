extends Node

class_name BaseInteraction

@onready var inventory_controller: InventoryController = $"/root/Gameplay/InventoryController"
@onready var message_controller: MessageController = $"/root/Gameplay/MessageController"

func interact() -> bool:
    return false
