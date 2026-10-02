class_name MegaphoneVoiceEffect
extends ItemEffect

var audio_player : MultiplayerAudioStreamPlayer3D = null
var is_on = false


func on_held(holder : Character):
	if holder and holder.has_node("RotationPivot/MultiplayerAudioStreamPlayer3D"):
		audio_player = holder.get_node("RotationPivot/MultiplayerAudioStreamPlayer3D")


func start_effect(holder : Character):
	if not audio_player:
		return
	if not is_on:
		audio_player.add_megaphone_effect.rpc()
	else:
		audio_player.remove_megaphone_effect.rpc()


func on_released():
	if audio_player:
		audio_player.remove_megaphone_effect.rpc()
		audio_player = null
