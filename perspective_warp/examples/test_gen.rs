use std::fs;

fn main() {
    let fonts_dir = std::path::PathBuf::from("../.fonts");
    let font_en =
        fs::read(fonts_dir.join("Times New Roman")).expect("failed to read Times New Roman");
    let font_km =
        fs::read(fonts_dir.join("Noto Serif Khmer")).expect("failed to read Noto Serif Khmer");

    // 1. Page 177 Fig 4 - English
    let config_fig4_en = serde_json::json!({
        "top_label": "The set of all natural numbers",
        "bot_label": "Part of that set",
        "top_start": 1,
        "top_step": 1,
        "bot_start": 2,
        "bot_step": 1,
        "rate": 0.00095,
        "width": 1000.0,
        "height": 240.0
    });
    let svg_fig4_en = perspective_warp::render(
        &font_en,
        &font_en,
        &serde_json::to_vec(&config_fig4_en).unwrap(),
    )
    .unwrap();
    let out_fig4_en = "../The Beginning of Infinity/_page_177_Figure_4-test-en.svg";
    fs::write(out_fig4_en, &svg_fig4_en).unwrap();
    println!("Generated {out_fig4_en}");

    // 2. Page 177 Fig 4 - Khmer
    let config_fig4_km = serde_json::json!({
        "top_label": "សំណុំនៃចំនួនធម្មជាតិទាំងអស់",
        "bot_label": "ផ្នែកមួយនៃសំណុំនោះ",
        "top_start": 1,
        "top_step": 1,
        "bot_start": 2,
        "bot_step": 1,
        "rate": 0.00095,
        "width": 1000.0,
        "height": 240.0
    });
    let svg_fig4_km = perspective_warp::render(
        &font_km,
        &font_km,
        &serde_json::to_vec(&config_fig4_km).unwrap(),
    )
    .unwrap();
    let out_fig4_km = "../The Beginning of Infinity/_page_177_Figure_4-test-km.svg";
    fs::write(out_fig4_km, &svg_fig4_km).unwrap();
    println!("Generated {out_fig4_km}");

    // 3. Page 180 Fig 1 - English (Natural vs Odd numbers)
    let config_fig1_en = serde_json::json!({
        "top_label": "Natural numbers",
        "bot_label": "Odd numbers",
        "top_start": 1,
        "top_step": 1,
        "bot_start": 1,
        "bot_step": 2,
        "rate": 0.00095,
        "width": 1000.0,
        "height": 240.0
    });
    let svg_fig1_en = perspective_warp::render(
        &font_en,
        &font_en,
        &serde_json::to_vec(&config_fig1_en).unwrap(),
    )
    .unwrap();
    let out_fig1_en = "../The Beginning of Infinity/_page_180_Figure_1-test-en.svg";
    fs::write(out_fig1_en, &svg_fig1_en).unwrap();
    println!("Generated {out_fig1_en}");

    // 4. Page 180 Fig 1 - Khmer
    let config_fig1_km = serde_json::json!({
        "top_label": "ចំនួនធម្មជាតិ",
        "bot_label": "ចំនួនសេស",
        "top_start": 1,
        "top_step": 1,
        "bot_start": 1,
        "bot_step": 2,
        "rate": 0.00095,
        "width": 1000.0,
        "height": 240.0
    });
    let svg_fig1_km = perspective_warp::render(
        &font_km,
        &font_km,
        &serde_json::to_vec(&config_fig1_km).unwrap(),
    )
    .unwrap();
    let out_fig1_km = "../The Beginning of Infinity/_page_180_Figure_1-test-km.svg";
    fs::write(out_fig1_km, &svg_fig1_km).unwrap();
    println!("Generated {out_fig1_km}");
}
