extends "res://test/framework/test.gd"


func title():
	return "FP"


func test_patch_dictionary_inner():
	var source = {
		id = "source_id",
		label = "label",
		inner = { id = "source_dict_id", label = "dict_label" },
	}

	var patch = {
		id = "patch_id",
		inner = { id = "patch_dict_id" },
	}

	var result = FP.patch_dictionary(source, patch)
	var expected = {
		id = "patch_id",
		label = "label",
		inner = { id = "patch_dict_id", label = "dict_label" }
	}

	assert_contains(result, expected)
	

func test_patch_dictionary_diff_key_types():
	var source = {
		id = "source_id",
		label = "label",
		inner = [ "source_dict_id", "dict_label" ],
	}
	var patch = {
		id = "patch_id",
		inner = { "0": "patch_dict_id" },
	}

	var result = FP.patch_dictionary(source, patch)
	var expected = {
		id = "patch_id",
		label = "label",
		inner = { "0": "patch_dict_id" }
	}

	assert_contains(result, expected)
