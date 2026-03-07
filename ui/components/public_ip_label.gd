class_name PublicIpLabel
extends Label


func _ready():
	var upnp = UPNP.new()
	upnp.discover(2000, 2, "InternetGatewayDevice")
	text = "Public IP: %s" % upnp.query_external_address()
