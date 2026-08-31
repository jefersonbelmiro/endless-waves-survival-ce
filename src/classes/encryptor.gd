extends Reference
class_name Encryptor

const PADING_CHAR = '#'

static func encrypt(key: String, data: String):
	var base64_data = Marshalls.variant_to_base64(data)
	while base64_data.length() % 16 != 0:
		base64_data += PADING_CHAR
	while key.length() % 16 != 0:
		key += PADING_CHAR
	var raw_data = base64_data.to_utf8()
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, key.to_utf8(), raw_data)
	var encrypted = aes.update(raw_data)
	aes.finish()
	return Marshalls.raw_to_base64(encrypted)


static func decrypt(key: String, data: String):
	while key.length() % 16 != 0:
		key += PADING_CHAR
	var raw_data = Marshalls.base64_to_raw(data)
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_DECRYPT, key.to_utf8(), raw_data)
	var decrypted = aes.update(raw_data)
	aes.finish()
	var regex = RegEx.new()
	regex.compile("[%s]*$" % [PADING_CHAR])
	var base64 = regex.sub(decrypted.get_string_from_utf8(), "", true)
	return Marshalls.base64_to_variant(base64)
	

static func encrypt_file(path: String, key: String, data: String):
	var file = File.new()
	var error = file.open_encrypted_with_pass(path, File.WRITE, key)
	if error != OK:
		return error
	file.store_string(data)
	file.close()
	return OK


static func decrypt_file(path: String, key: String):
	var file = File.new()
	if !file.file_exists(path):
		return null
	var error = file.open_encrypted_with_pass(path, File.READ, key)
	if error != OK:
		return null
	var data = file.get_as_text()
	file.close()
	return data
	
