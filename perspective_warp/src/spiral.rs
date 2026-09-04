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

pub fn render(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let config: GeneSpiralConfig =
        serde_json::from_slice(config_bytes).map_err(|e| format!("Invalid JSON config: {e}"))?;
    let n_nodes = config.nodes_per_turn;
    let theta_step = std::f32::consts::TAU / n_nodes as f32;
    let theta_0 = config.theta_offset_deg.to_radians();
    let tilt_rad = config.tilt_deg.to_radians();
    let cos_tilt = tilt_rad.cos();
    let sin_tilt = tilt_rad.sin();

    // `gap` controls the distance between one black repetition and the next black repetition.
    // Grey is always in the middle between two repetitions of black (gap * 0.5).
    let step_u = config.gap / n_nodes as f32;
    let gray_offset = config.gap * 0.5;

    let camera = PerspectiveCamera::new(
        config.start_x,
        config.start_y,
        config.vanish_x,
        config.vanish_y,
        config.rate,
    );

    let axis_dx = config.vanish_x - config.start_x;
    let axis_dy = config.vanish_y - config.start_y;
    let axis_len = (axis_dx * axis_dx + axis_dy * axis_dy).sqrt().max(1e-4);
    let ux = axis_dx / axis_len;
    let uy = axis_dy / axis_len;

    // 3D point projected to 2D screen coordinates, returning ((px, py), z, d_par)
    // Points tilted along the receding axis (d_par > 0) are in the back.
    // Points tilted towards the viewer (d_par <= 0) are in the front.
    let get_projected_point = |u: f32, theta: f32| -> ((f32, f32), f32, f32) {
        let s = camera.scale(u);
        let (cx, cy) = camera.axis_point(u);
        let cos_t = theta.cos();
        let sin_t = theta.sin();

        let dx_raw = config.radius_x * cos_t;
        let dy_raw = config.radius_y * sin_t;

        let dx = (dx_raw * cos_tilt - dy_raw * sin_tilt) * s;
        let dy = (dx_raw * sin_tilt + dy_raw * cos_tilt) * s;

        let px = cx + dx;
        let py = cy + dy;
        let d_par = (dx * ux + dy * uy) / s;
        let z = u + (dx * ux + dy * uy);
        ((px, py), z, d_par)
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

    enum DrawableKind {
        Spoke {
            center: (f32, f32),
            node: (f32, f32),
            is_front: bool,
            dot_color: String,
            scale: f32,
        },
        Segment {
            p1: (f32, f32),
            p2: (f32, f32),
            is_front: bool,
            color: String,
            scale: f32,
        },
        ApexLine {
            p1: (f32, f32),
            p2: (f32, f32),
            color: String,
            scale: f32,
        },
    }

    struct Drawable {
        z: f32,
        kind: DrawableKind,
    }

    let mut drawables: Vec<Drawable> = Vec::with_capacity(2048);

    // Helper to generate spokes and segments for a spiral
    let mut add_spiral = |offset_u: f32, color: &str| {
        let mut m = 0;
        let mut last_node: Option<((f32, f32), f32, f32)> = None;

        while m < 10000 {
            let u = m as f32 * step_u + offset_u;
            let theta = theta_0 + m as f32 * theta_step;
            let s = camera.scale(u);
            let (cx, _) = camera.axis_point(u);

            if cx >= config.vanish_x - 1.0 || s < 0.012 {
                break;
            }

            let (pt, z, d_par) = get_projected_point(u, theta);
            let center = camera.axis_point(u);
            let is_front = d_par <= 0.0;

            // Add spoke
            drawables.push(Drawable {
                z,
                kind: DrawableKind::Spoke {
                    center,
                    node: pt,
                    is_front,
                    dot_color: color.to_string(),
                    scale: s,
                },
            });

            // Add segment connecting previous node
            let u_next = (m + 1) as f32 * step_u + offset_u;
            let theta_next = theta_0 + (m + 1) as f32 * theta_step;
            let (pt_next, z_next, d_par_next) = get_projected_point(u_next, theta_next);
            let s_next = camera.scale(u_next);

            let seg_z = (z + z_next) * 0.5;
            let seg_is_front = ((d_par + d_par_next) * 0.5) <= 0.0;

            drawables.push(Drawable {
                z: seg_z,
                kind: DrawableKind::Segment {
                    p1: pt,
                    p2: pt_next,
                    is_front: seg_is_front,
                    color: color.to_string(),
                    scale: (s + s_next) * 0.5,
                },
            });

            last_node = Some((pt, z, s));
            m += 1;
        }

        if let Some((pt, z, s)) = last_node {
            drawables.push(Drawable {
                z: z + 100.0, // Furthest away, drawn earliest
                kind: DrawableKind::ApexLine {
                    p1: pt,
                    p2: (config.vanish_x, config.vanish_y),
                    color: color.to_string(),
                    scale: s,
                },
            });
        }
    };

    add_spiral(0.0, &config.black_color);
    add_spiral(gray_offset, &config.gray_color);

    // Sort all drawables by depth Z in descending order:
    // Furthest away (largest Z) is rendered first; nearest (smallest Z) is rendered on top.
    drawables.sort_by(|a, b| b.z.partial_cmp(&a.z).unwrap_or(std::cmp::Ordering::Equal));

    for d in drawables {
        match d.kind {
            DrawableKind::Spoke {
                center,
                node,
                is_front,
                dot_color,
                scale,
            } => {
                if !is_front {
                    let sw = (0.75 * scale).clamp(0.2, 0.85);
                    let dash1 = (1.2 * scale).clamp(0.5, 1.5);
                    let dash2 = (1.8 * scale).clamp(0.8, 2.2);
                    let _ = writeln!(
                        svg,
                        r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="{:.2},{:.2}" stroke-linecap="round"/>"#,
                        center.0, center.1, node.0, node.1, config.spoke_color, sw, dash1, dash2
                    );
                } else {
                    let sw = (0.95 * scale).clamp(0.25, 1.05);
                    let dash1 = (1.4 * scale).clamp(0.6, 1.8);
                    let dash2 = (2.0 * scale).clamp(0.9, 2.5);
                    let dot_r = (1.6 * scale).clamp(0.5, 1.75);
                    let _ = writeln!(
                        svg,
                        r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="{:.2},{:.2}" stroke-linecap="round"/>"#,
                        center.0, center.1, node.0, node.1, config.spoke_color, sw, dash1, dash2
                    );
                    let _ = writeln!(
                        svg,
                        r#"    <circle cx="{:.2}" cy="{:.2}" r="{:.2}" fill="{}"/>"#,
                        node.0, node.1, dot_r, dot_color
                    );
                }
            }
            DrawableKind::Segment {
                p1,
                p2,
                is_front,
                color,
                scale,
            } => {
                if !is_front {
                    let sw =
                        (config.stroke_base * 0.65 * scale).clamp(0.35, config.stroke_base * 0.7);
                    let _ = writeln!(
                        svg,
                        r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round" stroke-linejoin="round"/>"#,
                        p1.0, p1.1, p2.0, p2.1, color, sw
                    );
                } else {
                    let sw =
                        (config.stroke_base * 1.15 * scale).clamp(0.45, config.stroke_base * 1.3);
                    let _ = writeln!(
                        svg,
                        r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round" stroke-linejoin="round"/>"#,
                        p1.0, p1.1, p2.0, p2.1, color, sw
                    );
                }
            }
            DrawableKind::ApexLine {
                p1,
                p2,
                color,
                scale,
            } => {
                let sw = (config.stroke_base * 0.7 * scale).clamp(0.25, 0.5);
                let _ = writeln!(
                    svg,
                    r#"    <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round"/>"#,
                    p1.0, p1.1, p2.0, p2.1, color, sw
                );
            }
        }
    }

    let _ = writeln!(svg, "  </g>\n</svg>");
    Ok(svg.into_bytes())
}
