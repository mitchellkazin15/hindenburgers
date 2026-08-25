class_name Megaphone
extends HoldableItem

var audio_player : MultiplayerAudioStreamPlayer3D = null


func set_being_held(holder : Character):
	super.set_being_held(holder)
	if holder.has_node("RotationPivot/MultiplayerAudioStreamPlayer3D"):
		audio_player = holder.get_node("RotationPivot/MultiplayerAudioStreamPlayer3D")
		audio_player.add_megaphone_effect.rpc()


func release():
	if audio_player:
		audio_player.remove_megaphone_effect.rpc()
		audio_player = null
	super.release()
