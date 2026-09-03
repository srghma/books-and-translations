use crate::common::PerspectiveCamera;
use serde::Deserialize;
use std::fmt::Write as FmtWrite;

// ============================================================================
// Gene Spiral Configuration
// ============================================================================

#[derive(Deserialize, Debug)]
pub struct GeneSpiralConfig {
    pub width: f32,
    pub height: f32,
    pub start_x: f32,
    pub start_y: f32,
    pub vanish_x: f32,
    pub vanish_y: f32,
    pub radius_x: f32,
    pub radius_y: f32,
    pub nodes_per_turn: usize,
    pub num_turns: usize,
    pub rate: f32,
    pub pitch: f32,
    pub gap: f32,
    pub theta_offset_deg: f32,
    pub tilt_deg: f32,
    pub black_color: String,
    pub gray_color: String,
    pub spoke_color: String,
    pub axis_color: String,
    pub draw_axis: bool,
    pub stroke_base: f32,
}

// ============================================================================
// Spiral Rendering
// ============================================================================

struct SpiralNode {
    pt: (f32, f32),
    depth: f32,
    scale: f32,
    center: (f32, f32),
}

struct SpiralSegment {
    p1: (f32, f32),
    p2: (f32, f32),
    mid_depth: f32,
    scale: f32,
    color: String,
}

struct SpiralSpoke {
    center: (f32, f32),
    node: (f32, f32),
    depth: f32,
    scale: f32,
    dot_color: String,
}

pub fn render(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let config: GeneSpiralConfig =
        serde_json::from_slice(config_bytes).map_err(|e| format!("Invalid JSON config: {e}"))?;
    let n_nodes = config.nodes_per_turn;
    let theta_step = std::f32::consts::TAU / n_nodes as f32;
    let theta_0 = config.theta_offset_deg.to_radians();
    let tilt_rad = config.tilt_deg.to_radians();
    let cos_tilt = tilt_rad.cos();
    let sin_tilt = tilt_rad.sin();

    let step_u = config.pitch / n_nodes as f32;
    let gap = if config.gap > 0.0 {
        config.gap
    } else {
        step_u * 2.0
    };

    let camera = PerspectiveCamera::new(
        config.start_x,
        config.start_y,
        config.vanish_x,
        config.vanish_y,
        config.rate,
    );

    // 3D point projected to 2D
    let get_projected_point = |u: f32, theta: f32| -> ((f32, f32), f32) {
        let s = camera.scale(u);
        let (cx, cy) = camera.axis_point(u);
        let cos_t = theta.cos();
        let sin_t = theta.sin();

        let dx_raw = config.radius_x * cos_t;
        let dy_raw = config.radius_y * sin_t;

        let dx = (dx_raw * cos_tilt - dy_raw * sin_tilt) * s;
        let dy = (dx_raw * sin_tilt + dy_raw * cos_tilt) * s;

        let depth = cos_t;
        ((cx + dx, cy + dy), depth)
    };

    let mut svg = String::with_capacity(64 * 1024);
    let _ = writeln!(
        svg,
        r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {:.1} {:.1}" width="{:.1}" height="{:.1}">"#,
        config.width, config.height, config.width, config.height
    );

    let _ = writeln!(
        svg,
        r#"  <defs><clipPath id="spiral-clip"><rect width="{:.1}" height="{:.1}"/></clipPath></defs>"#,
        config.width, config.height
    );
    let _ = writeln!(svg, r#"  <g clip-path="url(#spiral-clip)">"#);

    // 1. Central axis line towards vanishing point
    if config.draw_axis {
        let (x0, y0) = camera.axis_point(0.0);
        let (xv, yv) = (config.vanish_x, config.vanish_y);
        let _ = writeln!(
            svg,
            r#"    <line x1="{x0:.2}" y1="{y0:.2}" x2="{xv:.2}" y2="{yv:.2}" stroke="{}" stroke-width="0.75" stroke-dasharray="2.5,3.5" stroke-linecap="round"/>"#,
            config.axis_color
        );
    }

    // Build nodes for Spiral A (Black) and Spiral B (Gray), with aligned theta angles
    let mut nodes_a: Vec<SpiralNode> = Vec::with_capacity(512);
    let mut nodes_b: Vec<SpiralNode> = Vec::with_capacity(512);

    let mut m = 0;
    while m < 10000 {
        let theta = theta_0 + m as f32 * theta_step;

        // Spiral A: at u_a
        let u_a = m as f32 * step_u;
        let s_a = camera.scale(u_a);
        let (cx_a, _) = camera.axis_point(u_a);

        if cx_a >= config.vanish_x - 1.0 || s_a < 0.012 {
            break;
        }

        let (pt_a, depth_a) = get_projected_point(u_a, theta);
        let c_a = camera.axis_point(u_a);
        nodes_a.push(SpiralNode {
            pt: pt_a,
            depth: depth_a,
            scale: s_a,
            center: c_a,
        });

        // Spiral B: shifted by gap along axis, aligned in theta
        let u_b = u_a + gap;
        let s_b = camera.scale(u_b);
        let (cx_b, _) = camera.axis_point(u_b);

        if cx_b < config.vanish_x - 1.0 && s_b >= 0.012 {
            let (pt_b, depth_b) = get_projected_point(u_b, theta);
            let c_b = camera.axis_point(u_b);
            nodes_b.push(SpiralNode {
                pt: pt_b,
                depth: depth_b,
                scale: s_b,
                center: c_b,
            });
        }

        m += 1;
    }

    let mut segments: Vec<SpiralSegment> = Vec::with_capacity(nodes_a.len() + nodes_b.len());
    let mut spokes: Vec<SpiralSpoke> = Vec::with_capacity(nodes_a.len() + nodes_b.len());

    // Segments and spokes for Spiral A (Black)
    for i in 0..nodes_a.len() {
        let n = &nodes_a[i];
        spokes.push(SpiralSpoke {
            center: n.center,
            node: n.pt,
            depth: n.depth,
            scale: n.scale,
            dot_color: config.black_color.clone(),
        });

        if i + 1 < nodes_a.len() {
            let next = &nodes_a[i + 1];
            segments.push(SpiralSegment {
                p1: n.pt,
                p2: next.pt,
                mid_depth: (n.depth + next.depth) * 0.5,
                scale: (n.scale + next.scale) * 0.5,
                color: config.black_color.clone(),
            });
        }
    }

    // Segments and spokes for Spiral B (Gray)
    for i in 0..nodes_b.len() {
        let n = &nodes_b[i];
        spokes.push(SpiralSpoke {
            center: n.center,
            node: n.pt,
            depth: n.depth,
            scale: n.scale,
            dot_color: config.gray_color.clone(),
        });

        if i + 1 < nodes_b.len() {
            let next = &nodes_b[i + 1];
            segments.push(SpiralSegment {
                p1: n.pt,
                p2: next.pt,
                mid_depth: (n.depth + next.depth) * 0.5,
                scale: (n.scale + next.scale) * 0.5,
                color: config.gray_color.clone(),
            });
        }
    }

    // 2. Render Back Layer (depth < 0)
    // 2a. Back spokes
    for sp in spokes.iter().filter(|s| s.depth < 0.0) {
        let sw = (0.75 * sp.scale).clamp(0.2, 0.85);
        let dash1 = (1.2 * sp.scale).clamp(0.5, 1.5);
        let dash2 = (1.8 * sp.scale).clamp(0.8, 2.2);
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="{:.2},{:.2}" stroke-linecap="round"/>"#,
            sp.center.0, sp.center.1, sp.node.0, sp.node.1, config.spoke_color, sw, dash1, dash2
        );
    }

    // 2b. Back spiral segments
    for seg in segments.iter().filter(|s| s.mid_depth < 0.0) {
        let sw = (config.stroke_base * 0.65 * seg.scale).clamp(0.35, config.stroke_base * 0.7);
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round" stroke-linejoin="round"/>"#,
            seg.p1.0, seg.p1.1, seg.p2.0, seg.p2.1, seg.color, sw
        );
    }

    // 3. Render Front Layer (depth >= 0)
    // 3a. Front spokes
    for sp in spokes.iter().filter(|s| s.depth >= 0.0) {
        let sw = (0.95 * sp.scale).clamp(0.25, 1.05);
        let dash1 = (1.4 * sp.scale).clamp(0.6, 1.8);
        let dash2 = (2.0 * sp.scale).clamp(0.9, 2.5);
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="{:.2},{:.2}" stroke-linecap="round"/>"#,
            sp.center.0, sp.center.1, sp.node.0, sp.node.1, config.spoke_color, sw, dash1, dash2
        );
    }

    // 3b. Node dots at front vertices
    for sp in spokes.iter().filter(|s| s.depth >= 0.0) {
        let dot_r = (1.6 * sp.scale).clamp(0.5, 1.75);
        let _ = writeln!(
            svg,
            r#"    <circle cx="{:.2}" cy="{:.2}" r="{:.2}" fill="{}"/>"#,
            sp.node.0, sp.node.1, dot_r, sp.dot_color
        );
    }

    // 3c. Front spiral segments (thick, prominent)
    for seg in segments.iter().filter(|s| s.mid_depth >= 0.0) {
        let sw = (config.stroke_base * 1.15 * seg.scale).clamp(0.45, config.stroke_base * 1.3);
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round" stroke-linejoin="round"/>"#,
            seg.p1.0, seg.p1.1, seg.p2.0, seg.p2.1, seg.color, sw
        );
    }

    // 4. Connect final nodes to the vanishing point apex
    if let (Some(last_a), Some(last_b)) = (nodes_a.last(), nodes_b.last()) {
        let sw_a = (config.stroke_base * 0.7 * last_a.scale).clamp(0.25, 0.5);
        let sw_b = (config.stroke_base * 0.7 * last_b.scale).clamp(0.25, 0.5);
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round"/>"#,
            last_a.pt.0, last_a.pt.1, config.vanish_x, config.vanish_y, config.black_color, sw_a
        );
        let _ = writeln!(
            svg,
            r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round"/>"#,
            last_b.pt.0, last_b.pt.1, config.vanish_x, config.vanish_y, config.gray_color, sw_b
        );
    }

    let _ = writeln!(svg, "  </g>\n</svg>");
    Ok(svg.into_bytes())
}
