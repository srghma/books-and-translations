use std::fs;

fn main() {
    let config = serde_json::json!({
        "start_x": 35.0,
        "start_y": 105.0,
        "vanish_x": 245.0,
        "vanish_y": 105.0,
        "radius": 68.0,
        "gap_btw_turns": 25.0,
        "nodes_per_turn": 8,
        "thickness_of_non_warped_spiral": 2.4,
        "thickness_of_non_warped_axis": 0.8,
        "color": "#16181b",
        "axis_color": "rgba(130, 135, 142, 0.6)",
        "draw_axis": true,
        "color2": "#8b9097",
        "crossover_lines_color": "#686d75",
    });

    let config_bytes = serde_json::to_vec(&config).unwrap();
    let svg_bytes = perspective_warp::render_gene_spiral(&config_bytes).unwrap();
    let out_svg = "/tmp/test_spiral.svg";
    fs::write(out_svg, &svg_bytes).unwrap();
    println!("Wrote {out_svg}");
}
