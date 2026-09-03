use std::fs;

fn main() {
    let config = serde_json::json!({
        "width": 266.0,
        "height": 210.0,
        "start_x": 35.0,
        "start_y": 118.0,
        "vanish_x": 245.0,
        "vanish_y": 55.0,
        "radius_x": 52.0,
        "radius_y": 68.0,
        "nodes_per_turn": 8,
        "num_turns": 60,
        "rate": 0.0042,
        "pitch": 26.0,
        "gap": 6.5,
        "theta_offset_deg": -70.0,
        "tilt_deg": -10.0,
        "stroke_base": 2.4,
    });

    let config_bytes = serde_json::to_vec(&config).unwrap();
    let svg_bytes = perspective_warp::render_gene_spiral_internal(&config_bytes).unwrap();
    let out_svg = "/tmp/test_spiral.svg";
    fs::write(out_svg, &svg_bytes).unwrap();
    println!("Wrote {out_svg}");
}
