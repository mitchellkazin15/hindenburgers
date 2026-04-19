class_name SettingsFile
extends Resource

# Wrapping DisplayServer.WindowMode enum to have more readable names
enum WindowMode {
	WINDOWED = DisplayServer.WINDOW_MODE_WINDOWED,
	MINIMIZED = DisplayServer.WINDOW_MODE_MINIMIZED,
	MAXIMIZED = DisplayServer.WINDOW_MODE_MAXIMIZED,
	FULLSCREEN = DisplayServer.WINDOW_MODE_FULLSCREEN,
	EXCLUSIVE_FULLSCREEN = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
}

# Display Settings
@export var window_mode : WindowMode = WindowMode.WINDOWED

# Audio Settings
@export var mute : bool = false
@export_range(0.0, 1.0, 0.001) var master_volume_linear : float = 1.0
@export_range(0.0, 1.0, 0.001) var music_volume_linear : float = 0.5
@export_range(0.0, 1.0, 0.001) var sfx_volume_linear : float = 0.5
