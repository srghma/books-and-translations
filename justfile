set unstable
set lists

list_of_dirs := [
    "The Beginning of Infinity Explanations that Transform the World-marked",
    "The Fabric of Reality The Science of Parallel Universes and Its Implications-marked",
]

# Default target: list available commands
default:
    @just --list

# Deduplicate similar images across all directories in list_of_dirs
deduplicate-images *ARGS: *(deduplicate-dir *list_of_dirs ARGS)

# Preview deduplication (dry-run) across all directories in list_of_dirs
deduplicate-images-dry-run *ARGS:
    just deduplicate-images --dry-run {{ARGS}}

# Delete unreferenced images across all directories in list_of_dirs
delete-unreferenced-images *ARGS: *(delete-unreferenced-dir *list_of_dirs ARGS)

# Preview unreferenced images to delete (dry-run) across all directories in list_of_dirs
delete-unreferenced-images-dry-run *ARGS:
    just delete-unreferenced-images --dry-run {{ARGS}}

# Deduplicate similar images for a specific book directory
deduplicate-dir dir *ARGS:
    uv run ./deduplicate_similar_images.py {{ARGS}} "{{dir}}"

# Delete unreferenced images for a specific book directory
delete-unreferenced-dir dir *ARGS:
    uv run ./delete_unreferenced_images.py {{ARGS}} "{{dir}}"
