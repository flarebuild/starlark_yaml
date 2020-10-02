def _is_valid_line_start(ch):
    return ch == '-' or ch == '"' or ch.isalpha() or ch.isdigit()

def _check_line_for_ident(line):
    indent_ws = 0
    for i in range( len(line) ):
        ch = line[i]
        if ch == ' ':
            indent_ws += 1
        elif ch == '#':
            return None
        elif _is_valid_line_start(ch):
            return (indent_ws, line[indent_ws:])
        else:
            fail("parse error: " + line)
    return None

def _sanitize_str(val):
    if not val:
        return None
    val = val.strip()
    if val[0] == '"' and val[len(val) - 1] == '"':
        val = val[1:len(val) - 1]
    return val

def _line_def(line):
    is_array_elem = False
    if line[0] == '-' and line[1] == ' ':
        is_array_elem = True
        line = line[2:]
    key_end_pos = None
    prev_is_colon = False
    for i in range( len(line) ):
        ch = line[i]
        if prev_is_colon:
            if ch == " ":
                if key_end_pos:
                    fail("parse error: " + line)
                key_end_pos = i - 1
            prev_is_colon = False
        if ch == ":":
            prev_is_colon = True

    if prev_is_colon:
        if is_array_elem or key_end_pos:
            fail("parse error: " + line)
        last_pos = len(line) - 1
    else:
        last_pos = len(line)

    return struct(
        is_array_elem = is_array_elem,
        is_end_colon = prev_is_colon,
        key = _sanitize_str(line[:key_end_pos] if key_end_pos else line[:last_pos]),
        value = _sanitize_str(line[key_end_pos + 2:last_pos] if key_end_pos else None),
    )

def _parse_new_state(line_def, cur_indent):
    array_processing = line_def.is_array_elem
    return {
        "array_processing": array_processing,
        "cur_indent": cur_indent,
        "cur": [] if array_processing else {},
    }

def _check_state(cur_state, indent_ws, line_def, line):
    if not cur_state:
        if indent_ws != 0:
            fail("wrong indentation at: " + line)
        return (_parse_new_state(line_def, 0), None)

    indent_ws_change = indent_ws - (cur_state["cur_indent"] * 2)
    if (indent_ws_change % 2) != 0:
        fail("wrong indentation at: " + line)

    if indent_ws_change == 0:
        if cur_state["expecting_nested"]:
            fail("wrong indentation at: " + line)
        if line_def.is_array_elem and not cur_state["array_processing"]:
            fail("parse error: " + line)
    elif indent_ws_change < 0:
        if cur_state["expecting_nested"]:
            fail("wrong indentation at: " + line)
        return (None, (indent_ws_change * -1) // 2)
    elif indent_ws_change == 2:
        may_expect_nested = cur_state["may_expect_nested"]
        if not cur_state["expecting_nested"] and not may_expect_nested:
            fail("wrong indentation at: " + line)
        cur_state["expecting_nested"] = False
        cur_state["may_expect_nested"] = False
        return (_parse_new_state(line_def, cur_state["cur_indent"] + 1), None)
    else:
        fail("wrong indentation at: " + line)

    cur_state["expecting_nested"] = line_def.is_end_colon
    return (cur_state, None)

def _insert(cur_state, key, value):
    if cur_state["array_processing"]:
        if value:
            if type(key) == "dict":
                key.update(value)
                return 
            else:
                to_add = { key: value }
        else:
            to_add = key
        cur_state["cur"].append(to_add)
    else:
        cur_state["cur"][key] = value

def _process_line_def(cur_state, line_def):
    expecting_nested = line_def.is_end_colon
    cur_state["expecting_nested"] = expecting_nested
    may_expect_nested = cur_state["array_processing"] and line_def.value != None
    cur_state["may_expect_nested"] = may_expect_nested
    
    if expecting_nested:
        cur_state["cur_advance_key"] = line_def.key
    else:
        _insert(cur_state, line_def.key, line_def.value)
        if may_expect_nested:
            cur =  cur_state["cur"]
            cur_state["cur_advance_key"] = cur[ len(cur) - 1 ]
        else:
            cur_state["cur_advance_key"] = None

def _backward(prev_state, prev_states, count):
    if not count:
        return prev_state
    for _ in range(count):
        cur_state = prev_states[0]
        prev_states.pop(0)
        prev_value = prev_state["cur"]
        cur_advance_key = cur_state["cur_advance_key"]
        if cur_advance_key:
            _insert(cur_state, cur_advance_key, prev_value)
        else:
            _insert(cur_state, prev_value, None)
        prev_state = cur_state
    return cur_state

def load_yaml(content):
    prev_states = []
    cur_state = None

    for line in content.split("\n"):
        line_check_res =  _check_line_for_ident(line)
        if line_check_res == None:
            continue

        line_def = _line_def(line_check_res[1])

        prev_state = cur_state
        check_res = _check_state(cur_state, line_check_res[0], line_def, line)
        cur_state = check_res[0]

        if not cur_state and not prev_state:
            fail("logic error")
        elif cur_state != prev_state:
            if not cur_state:
                cur_state = _backward(prev_state, prev_states, check_res[1])
            elif prev_state:
                prev_states.insert(0, prev_state)

        _process_line_def(cur_state, line_def)

    return _backward(cur_state, prev_states, len(prev_states))["cur"]
