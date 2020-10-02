load("//:yaml.bzl", "load_yaml")
load("//:tests/validate_yaml.bzl", "validate_yaml")

def _test_yaml_impl(ctx):
    yaml = load_yaml(ctx.attr.content)
    validate_yaml(yaml)

test_yaml = rule(
    implementation = _test_yaml_impl,
    attrs = {
        "content": attr.string(mandatory = True)
    }
)

_REPO_TEST_BZL = """
load("@//:tests/validate_yaml.bzl", "validate_yaml")

_YAML_REPO_PARSED = %s

def _test_yaml_impl(ctx):
    validate_yaml(_YAML_REPO_PARSED)

test_yaml = rule(implementation = _test_yaml_impl)
"""

_REPO_BUILD = """
load("//:test.bzl", "test_yaml")
test_yaml(name = "test_yaml")
"""

def _test_repo_yaml_impl(repository_ctx):
    yaml = load_yaml(repository_ctx.read(repository_ctx.attr.yaml_file))
    validate_yaml(yaml)
    repository_ctx.file("BUILD.bazel", _REPO_BUILD)
    repository_ctx.file("test.bzl", _REPO_TEST_BZL % str(yaml))

test_repo_yaml = repository_rule(
    implementation = _test_repo_yaml_impl,
    attrs = {
        "yaml_file": attr.label(mandatory = True),
    }
)