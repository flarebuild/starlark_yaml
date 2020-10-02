load("//:yaml.bzl", "load_yaml")
load("//:tests/validate_yaml.bzl", "validate_yaml", "assert_equal")
load("@test_repo_yaml//:tests/test_content.yaml.bzl", _repo_yaml = "CONTENT")

def _test_yaml_impl(ctx):
    yaml = load_yaml(ctx.attr.content)
    validate_yaml(yaml)
    validate_yaml(_repo_yaml)
    assert_equal(yaml, _repo_yaml)

test_yaml = rule(
    implementation = _test_yaml_impl,
    attrs = {
        "content": attr.string(mandatory = True)
    }
)