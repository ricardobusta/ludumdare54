extends Node

class_name MessageController

const DEFAULT_DURATION: float = 1.5

@export var message_label: Label = null

@onready var _timer: Timer = $Timer

func _ready():
    _timer.connect("timeout", Callable(self, "_clear_message"))
    _clear_message()

func show_message(message: String, duration: float = DEFAULT_DURATION):
    if message == "":
        return
    message_label.text = message
    _timer.start(duration)

func _clear_message():
    message_label.text = ""
