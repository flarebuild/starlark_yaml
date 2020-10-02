TEST_CONTENT = """
root_1:
  inner_1:
    # some comment
    inner_inner_1:
            # some comment
      some_key: some_value
      some_int_key: 123
      some_another_key: "some_quoted_value"
    inner_inner_2:
      some_key: some_value
      some_nested_array:
        - whoop1
        - whoop2
      some_other_key: some_other_value
  inner_2:
    # some comment
    inner_inner_1:
            # some comment
      some_key: some_value
      some_int_key: 123
      some_another_key: "some_quoted_value"
    inner_inner_2:
      some_key: some_value
      some_nested_array:
        - whoop1
        - whoop2
      some_other_key: some_other_value
"root_2": root2_value
root_3:
  inner_1:
    - one_value_in_array
  inner_2:
    some_key: some_value:with_colon
  inner_3:
    - some_key: some_value
      some_int_key: 123
      some_another_key: "some_quoted_value"
    - some_key: some_value
      some_int_key: 123
      some_another_key: "some_quoted_value"
  inner_4:
    some_key: some_value
"""