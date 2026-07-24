extends Node

const PROFILE_PATH := "user://star_stream/profile.tres"
var profile: LocalUserProfileData

func _ready() -> void:
	if ResourceLoader.exists(PROFILE_PATH):
		profile = ResourceLoader.load(PROFILE_PATH)
	else:
		profile = LocalUserProfileData.new()
		# Dependency on DataManager autoload setup
		# It's safer to generate a simple UUID-like string if DataManager ain't ready
		profile.user_id = str(randi()) + "_" + str(Time.get_ticks_msec())
		profile.display_name = "Player"
		profile.app_version = ProjectSettings.get_setting("application/config/version", "0.1.0")
		ResourceSaver.save(profile, PROFILE_PATH)

func save_profile() -> void:
	ResourceSaver.save(profile, PROFILE_PATH)
