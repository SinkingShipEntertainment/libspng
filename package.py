name = "libspng"

authors = [
    "Randy"
]

version = "0.7.3.sse.1.0.0"

description = \
    """
    Simple PNG library
    """

with scope("config") as c:
    # Determine location to release: internal (int) vs external (ext)

    # NOTE: Modify this variable to reflect the current package situation
    release_as = "ext"

    # The `c` variable here is actually rezconfig.py
    # `release_packages_path` is a variable defined inside rezconfig.py

    import os
    if release_as == "int":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_INT"]
    elif release_as == "ext":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_EXT"]

requires = [
]

private_build_requires = [
]

variants = [
    ["platform-linux", "arch-x86_64", "os-centos-7"]
]

tools = [
]

uuid = "repository.libspng"

def pre_build_commands():
    command("source /opt/rh/devtoolset-6/enable")

def commands():
    # NOTE: REZ package versions can have ".sse." to separate the external
    # version from the internal modification version.
    split_versions = str(version).split(".sse.")
    external_version = split_versions[0]
    internal_version = None
    if len(split_versions) == 2:
        internal_version = split_versions[1]

    env.LIBSPNG_VERSION = external_version
    env.LIBSPNG_PACKAGE_VERSION = external_version
    if internal_version:
        env.LIBSPNG_PACKAGE_VERSION = internal_version

    env.SPNG_ROOT = "{root}"
    env.SPNG_LOCATION = "{root}"
    env.LD_LIBRARY_PATH.append("{root}/lib")
