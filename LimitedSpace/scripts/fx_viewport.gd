extends Viewport

func _ready() -> void:
    update_viewport()
    get_tree().root.connect("size_changed", Callable(self, "update_viewport"))

func update_viewport() -> void:
    self.size = get_tree().root.size
