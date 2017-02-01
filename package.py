import shutil, errno, os


author = "klamann"
app_name = "bigger train stations"
version = "1.0-beta2"

build_dir = "./.build"
dist_dir = "./dist"
app_dir_base = "_".join((author, app_name.replace(" ", "_"), "1"))
app_dir = os.path.join(build_dir, app_dir_base)
zip_name = "_".join((app_name.replace(" ", "-"), version))
zip_file = os.path.join(dist_dir, zip_name)

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
    shutil.make_archive(zip_file, 'zip', root_dir=build_dir, base_dir=app_dir_base)
    print("archive has been created: '{}.zip'".format(zip_file))


if __name__ == "__main__":
    build()
