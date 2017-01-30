import shutil, errno, os


author = "klamann"
app_name = "bigger train stations"
version = "1.0-beta"

build_dir = "./.build"
dist_dir = "./dist"
app_dir_base = "_".join((author, app_name.replace(" ", "_"), "1"))
app_dir = os.path.join(build_dir, app_dir_base)
zip_name = "_".join((author, app_name.replace(" ", "_"), version))

distribution_files = [
    "res",
    "mod.lua",
    "strings.lua",
    "image_00.tga",
    "workshop_fileid.txt",
    "workshop_preview.jpg",
    "Filebase.md",
    "Workshop.md"
]


def copyanything(src, dst):
    try:
        shutil.copytree(src, dst)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise


def build():
    shutil.rmtree(app_dir, ignore_errors=True)
    os.makedirs(app_dir, exist_ok=True)
    os.makedirs(dist_dir, exist_ok=True)
    for file in distribution_files:
        copyanything(file, os.path.join(app_dir, file))
    shutil.make_archive(os.path.join(dist_dir, zip_name), 'zip', root_dir=build_dir, base_dir=app_dir_base)


if __name__ == "__main__":
    build()
