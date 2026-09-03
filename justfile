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

deduplicate-images *ARGS:*(deduplicate-dir *list_of_dirs ARGS)

# Preview deduplication (dry-run) across all directories in list_of_dirs

deduplicate-images-dry-run *ARGS:
    just deduplicate-images --dry-run {{ARGS}}

# Delete unreferenced images across all directories in list_of_dirs

delete-unreferenced-images *ARGS:*(delete-unreferenced-dir *list_of_dirs ARGS)

# Preview unreferenced images to delete (dry-run) across all directories in list_of_dirs

delete-unreferenced-images-dry-run *ARGS:
    just delete-unreferenced-images --dry-run {{ARGS}}

# Convert markdown files to Typst (.typ) across all directories in list_of_dirs (pass -c to also compile PDF)

convert-to-typst *ARGS:*(convert-to-typst-dir *list_of_dirs ARGS)

# Format all Typst (.typ) files across all directories in list_of_dirs using typstyle

format-typst *ARGS:*(format-typst-dir *list_of_dirs ARGS)

# Deduplicate similar images for a specific book directory

deduplicate-dir dir *ARGS:
    uv run ./deduplicate_similar_images.py {{ARGS}} "{{dir}}"

# Delete unreferenced images for a specific book directory

delete-unreferenced-dir dir *ARGS:
    uv run ./delete_unreferenced_images.py {{ARGS}} "{{dir}}"

# Convert markdown files to Typst for a specific book directory

convert-to-typst-dir dir *ARGS:
    ./convert_markdown_to_typst.py {{ARGS}} "{{dir}}"

# Format all Typst files for a specific book directory using typstyle

format-typst-dir dir *ARGS:
    typstyle -i "{{dir}}"/*.typ {{ARGS}}

# Split markdown file into individual chapters by contents

split-by-contents *ARGS:
    ./split_markdown_by_contents.py {{ARGS}}

# Regenerate fonts-to-ttf-path.json mapping font names to absolute font paths

generate-fonts-to-ttf-path:
    ./generate_fonts_to_ttf_path.py
