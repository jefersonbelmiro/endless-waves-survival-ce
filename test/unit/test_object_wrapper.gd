extends "res://test/framework/test.gd"


func title():
	return "ObjectWrapper"


func test_option_disabled_true():
	var object = { disabled = true }
	ObjectWrapper.new(object, { disabled = true })
	assert_eq(object.disabled, true)


func test_option_disabled_false():
	var object = { disabled = true }
	ObjectWrapper.new(object, { disabled = false })
	assert_eq(object.disabled, false)


func test_disabled_true_withou_options():
	var object = { disabled = true }
	ObjectWrapper.new(object)
	assert_eq(object.disabled, true)


func test_disabled_false_withou_options():
	var object = { disabled = false }
	ObjectWrapper.new(object)
	assert_eq(object.disabled, false)
	

func test_disabled_count():
	var object = { disabled = false }

	var wrapper = ObjectWrapper.new(object, { disabled = true })
	assert_eq(wrapper.disabled_count, 1)
	assert_eq(object.disabled, true)

	wrapper.set_disabled(true)
	assert_eq(wrapper.disabled_count, 2)
	assert_eq(object.disabled, true)

	wrapper.set_disabled(true)
	assert_eq(wrapper.disabled_count, 3)
	assert_eq(object.disabled, true)

	wrapper.set_disabled(false)
	assert_eq(wrapper.disabled_count, 2)
	assert_eq(object.disabled, true)

	wrapper.set_disabled(false)
	assert_eq(wrapper.disabled_count, 1)
	assert_eq(object.disabled, true)

	wrapper.set_disabled(false)
	assert_eq(wrapper.disabled_count, 0)
	assert_eq(object.disabled, false)
