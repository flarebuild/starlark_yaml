def _fial(msg):
    fail(msg)

def _assert(x):
    if not x:
        _fial("assertion failure: %s" % x)

def _assert_equal(one, two):
    if one != two:
        _fial("%s is not %s" % (one, two))

assert_equal = _assert_equal

def _check_inner_inner_block(yaml):
    # print(yaml)
    _assert_equal(yaml["some_key"], "some_value")
    _assert_equal(int(yaml["some_int_key"]), 123)
    _assert_equal(yaml["some_another_key"], "some_quoted_value")

def _check_inner_block(yaml, name):
    _assert(name in yaml)
    yaml = yaml[name]

    _assert("inner_inner_1" in yaml)
    _check_inner_inner_block(yaml["inner_inner_1"])
    _assert("inner_inner_2" in yaml)
    _assert_equal(yaml["inner_inner_2"]["some_key"], "some_value")
    _assert_equal(yaml["inner_inner_2"]["some_nested_array"], ["whoop1", "whoop2"])    

def _check_another_inner_block(yaml, name):
    _assert(name in yaml)
    yaml = yaml[name]

    _assert_equal(yaml["inner_1"], ["one_value_in_array"])
    _assert_equal(yaml["inner_2"]["some_key"], "some_value:with_colon")
    _check_inner_inner_block(yaml["inner_3"][0])
    _check_inner_inner_block(yaml["inner_3"][1])


def validate_yaml(yaml):
    _assert("root_1" in yaml)
    _check_inner_block(yaml["root_1"], "inner_1")
    _check_inner_block(yaml["root_1"], "inner_2")
    _assert("root_2" in yaml)
    _assert_equal(yaml["root_2"], "root2_value")
    _check_another_inner_block(yaml, "root_3")