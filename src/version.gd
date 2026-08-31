class_name Version

const CURRENT = 'v0.24.0'
const MIGRATIONS = {
	'v0.4.0': "migrate_v0_4_0",
	'v0.5.0': "migrate_v0_5_0",
	'v0.6.0': "migrate_v0_6_0",
	'v0.7.0': "migrate_v0_7_0",
	'v0.7.1': "migrate_v0_7_1",
	'v0.9.0': "migrate_v0_9_0",
	'v0.14.0': "migrate_v0_14_0",
	'v0.16.0': "migrate_v0_16_0",
	'v0.19.0': "migrate_v0_19_0",
	'v0.21.0': "migrate_v0_21_0",
	'v0.22.0': "migrate_v0_22_0",
	'v0.24.0': "migrate_v0_24_0",
}

static func migrate(persisted_data, target_version = CURRENT):
	# already migrated
	if 'version' in persisted_data && persisted_data.version == target_version:
		return persisted_data

	var target_version_number = _get_version_number(target_version)

	# migrate all avaliable migrations
	var current_version = persisted_data.version if 'version' in persisted_data else 'v0.0.0'
	var current_version_number = _get_version_number(current_version)
	
	for version_key in MIGRATIONS.keys():
		var version_number = _get_version_number(version_key)
		var handler = MIGRATIONS[version_key]
		if version_number > target_version_number:
			break
		if version_number > current_version_number:
			persisted_data = _call_handler(handler, version_key, persisted_data)
			current_version_number = version_number
	return persisted_data


static func _call_handler(handler: String, version_key: String, persisted_data):
	var ref = funcref(VersionMigration, handler) 
	var result = ref.call_func(persisted_data)
	result.version = version_key
	return result


static func _get_version_number(version: String):
	return float(version.replace('v', '').replacen(".", ''))
	
