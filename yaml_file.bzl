load("//:yaml.bzl", "load_yaml")

YamlFileContentProvider = provider(
    doc = "yaml file content parsed to starlark dict",
    fields = {
        "content": "yaml file content parsed to starlark dict"
    }
)

_BUILD_CONTENT = """
load("//:%s", "yaml_file_content")
yaml_file_content(
    name = "content",
    visibility = ["//visibility:public"],
)
"""

_BZL_CONTENT = """
load("@com_flarebuild_starlark_yaml//:yaml_file.bzl", "YamlFileContentProvider")

CONTENT = %s

def _yaml_file_content_impl(ctx):
    return [ YamlFileContentProvider(content = CONTENT) ]

yaml_file_content = rule(implementation = _yaml_file_content_impl)
"""


def _yaml_file_impl(repository_ctx):
    yaml = load_yaml(repository_ctx.read(repository_ctx.attr.src))
    parsed_file_name = repository_ctx.attr.src.name + ".bzl"
    repository_ctx.file("BUILD.bazel", _BUILD_CONTENT % parsed_file_name)
    repository_ctx.file(parsed_file_name, _BZL_CONTENT % str(yaml))

yaml_file = repository_rule(
    implementation = _yaml_file_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    }
)