use serde::Deserialize;
use std::fmt::Write as FmtWrite;

// ============================================================================
// Gene Spiral Configuration
// ============================================================================

#[derive(Deserialize, Debug)]
pub struct GeneSpiralConfig {
    pub start_x: f32,
    pub start_y: f32,
    pub vanish_x: f32,
    pub vanish_y: f32,

    pub radius: f32,
    pub nodes_per_turn: usize,
    pub gap_btw_turns: f32,

    pub thickness_of_non_warped_spiral: f32,
    pub thickness_of_non_warped_axis: f32,

    pub color: String,
    pub axis_color: String,
    pub draw_axis: bool,

    pub color2: Option<String>,
    pub crossover_lines_color: Option<String>,
}

// ============================================================================
// Spiral Rendering
// ============================================================================

pub fn render(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let config: GeneSpiralConfig =
        serde_json::from_slice(config_bytes).map_err(|e| format!("Invalid JSON config: {e}"))?;

    let sx = config.start_x;
    let sy = config.start_y;
    let vx = config.vanish_x;
    let vy = config.vanish_y;

    let axis_dx = vx - sx;
    let axis_dy = vy - sy;
    let axis_len = (axis_dx * axis_dx + axis_dy * axis_dy).sqrt();
    if axis_len < 1e-4 {
        return Ok(b"<svg xmlns=\"http://www.w3.org/2000/svg\"></svg>".to_vec());
    }

    // Unit tangent along axis (pointing from start towards vanishing point)
    let ux = axis_dx / axis_len;
    let uy = axis_dy / axis_len;

    // Unit normal perpendicular to axis in screen coordinates
    let nx = -uy;
    let ny = ux;

    let n_nodes = config.nodes_per_turn.max(3);
    let gap = config.gap_btw_turns.max(1.0);
    let step_u = gap / n_nodes as f32;
    let theta_step = std::f32::consts::TAU / n_nodes as f32;
    let theta_0 = (-90.0f32).to_radians();

    // Foreshortening ratio along axis when viewed at perspective angle
    let foreshorten = 0.75f32;

    // Perspective scale factor s(u) = L / (L + u)
    let scale_at = |u: f32| -> f32 { axis_len / (axis_len + u) };

    // Point on spiral in 2D coordinates centered and aligned around axis
    let get_point = |u: f32, theta: f32| -> ((f32, f32), f32, bool) {
        let s = scale_at(u);
        // Center along axis
        let cx = vx - ux * axis_len * s;
        let cy = vy - uy * axis_len * s;

        let cos_t = theta.cos();
        let sin_t = theta.sin();

        let d_par = config.radius * cos_t * foreshorten * s;
        let d_perp = config.radius * sin_t * s;

        let px = cx + d_par * ux + d_perp * nx;
        let py = cy + d_par * uy + d_perp * ny;

        let z = u + d_par;
        let is_front = d_par <= 0.0;
        ((px, py), z, is_front)
    };

    enum RenderItem {
        SpiralLine {
            z: f32,
            p1: (f32, f32),
            p2: (f32, f32),
            is_front: bool,
            scale: f32,
            color: String,
        },
        CrossoverStrand {
            z: f32,
            p1: (f32, f32),
            p2: (f32, f32),
            scale: f32,
            color: String,
        },
    }

    impl RenderItem {
        fn z(&self) -> f32 {
            match self {
                RenderItem::SpiralLine { z, .. } => *z,
                RenderItem::CrossoverStrand { z, .. } => *z,
            }
        }
    }

    let mut items: Vec<RenderItem> = Vec::with_capacity(2048);

    let mut min_x = sx.min(vx);
    let mut max_x = sx.max(vx);
    let mut min_y = sy.min(vy);
    let mut max_y = sy.max(vy);

    let mut add_spiral_turns = |phase_offset: f32, color_str: &str| {
        let theta_start = theta_0 + phase_offset;
        let mut m = 0;
        let mut last_p2 = (0.0, 0.0);
        let mut last_u = 0.0;
        let mut last_theta = 0.0;
        let mut last_s = 1.0;

        while m < 2000 {
            let u = m as f32 * step_u;
            let theta = theta_start + m as f32 * theta_step;

            let s = scale_at(u);
            let dist_to_vanish = axis_len * s;
            if dist_to_vanish < 3.5 || config.radius * s < 1.5 {
                last_u = u;
                last_theta = theta;
                last_s = s;
                break;
            }

            let (p1, z1, d_front1) = get_point(u, theta);

            let u_next = (m + 1) as f32 * step_u;
            let theta_next = theta_start + (m + 1) as f32 * theta_step;
            let (p2, z2, d_front2) = get_point(u_next, theta_next);
            let s_next = scale_at(u_next);

            min_x = min_x.min(p1.0).min(p2.0);
            max_x = max_x.max(p1.0).max(p2.0);
            min_y = min_y.min(p1.1).min(p2.1);
            max_y = max_y.max(p1.1).max(p2.1);

            let seg_z = (z1 + z2) * 0.5;
            let is_front = d_front1 || d_front2;

            items.push(RenderItem::SpiralLine {
                z: seg_z,
                p1,
                p2,
                is_front,
                scale: (s + s_next) * 0.5,
                color: color_str.to_string(),
            });

            last_p2 = p2;
            last_u = u_next;
            last_theta = theta_next;
            last_s = s_next;
            m += 1;
        }

        // Taper smoothly to a sharp needle point ending exactly at (vx, vy)
        let n_tip_steps = n_nodes * 2;
        let mut prev_pt = if m == 0 { get_point(0.0, theta_start).0 } else { last_p2 };
        let start_dist = axis_len * last_s;
        let start_radius = config.radius * last_s;

        for k in 1..=n_tip_steps {
            let t = k as f32 / n_tip_steps as f32;
            let decay = (1.0 - t).powf(1.8);
            let cur_dist = start_dist * decay;
            let cur_radius = start_radius * decay;
            let cur_theta = last_theta + k as f32 * theta_step;

            let cur_cx = vx - ux * cur_dist;
            let cur_cy = vy - uy * cur_dist;

            let cos_t = cur_theta.cos();
            let sin_t = cur_theta.sin();
            let d_par = cur_radius * cos_t * foreshorten;
            let d_perp = cur_radius * sin_t;

            let cur_pt = if k == n_tip_steps {
                (vx, vy)
            } else {
                (
                    cur_cx + d_par * ux + d_perp * nx,
                    cur_cy + d_par * uy + d_perp * ny,
                )
            };

            min_x = min_x.min(cur_pt.0);
            max_x = max_x.max(cur_pt.0);
            min_y = min_y.min(cur_pt.1);
            max_y = max_y.max(cur_pt.1);

            let cur_scale = last_s * decay;
            let is_front = d_par <= 0.0;

            items.push(RenderItem::SpiralLine {
                z: last_u + k as f32 * (step_u * 0.2),
                p1: prev_pt,
                p2: cur_pt,
                is_front,
                scale: cur_scale,
                color: color_str.to_string(),
            });

            prev_pt = cur_pt;
        }
    };

    add_spiral_turns(0.0, &config.color);
    if let Some(ref c2) = config.color2 {
        if !c2.is_empty() {
            add_spiral_turns(std::f32::consts::PI, c2);

            // Add crossover strands between black and grey spiral nodes
            if let Some(ref cross_col) = config.crossover_lines_color {
                if !cross_col.is_empty() {
                    let mut m = 0;
                    while m < 2000 {
                        let u = m as f32 * step_u;
                        let theta = theta_0 + m as f32 * theta_step;

                        let s = scale_at(u);
                        let dist_to_vanish = axis_len * s;
                        if dist_to_vanish < 12.0 || config.radius * s < 5.0 {
                            break;
                        }

                        let (p_black, _, _) = get_point(u, theta);
                        let (p_grey, _, _) = get_point(u, theta + std::f32::consts::PI);

                        items.push(RenderItem::CrossoverStrand {
                            z: u,
                            p1: p_black,
                            p2: p_grey,
                            scale: s,
                            color: cross_col.clone(),
                        });

                        m += 1;
                    }
                }
            }
        }
    }

    // Sort items by depth Z descending (back segments rendered first, front on top)
    items.sort_by(|a, b| b.z().partial_cmp(&a.z()).unwrap_or(std::cmp::Ordering::Equal));

    // Determine viewBox dimensions
    let pad = (config.thickness_of_non_warped_spiral * 1.5).max(3.0);
    let vb_x = min_x - pad;
    let vb_y = min_y - pad;
    let vb_w = (max_x - min_x) + 2.0 * pad;
    let vb_h = (max_y - min_y) + 2.0 * pad;

    let mut svg = String::with_capacity(32 * 1024);
    let _ = writeln!(
        svg,
        r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="{:.2} {:.2} {:.2} {:.2}" width="{:.2}" height="{:.2}">"#,
        vb_x, vb_y, vb_w, vb_h, vb_w, vb_h
    );

    // 1. Central axis line towards vanishing point
    if config.draw_axis {
        let _ = writeln!(
            svg,
            r#"  <line x1="{sx:.2}" y1="{sy:.2}" x2="{vx:.2}" y2="{vy:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="2.5,3.5" stroke-linecap="round"/>"#,
            config.axis_color, config.thickness_of_non_warped_axis
        );
    }

    // 2. Render sorted spiral segments and dotted crossover strands
    for item in items {
        match item {
            RenderItem::SpiralLine { p1, p2, is_front, scale, color, .. } => {
                let aggressive_scale = scale.powf(1.35);
                let sw = if !is_front {
                    (config.thickness_of_non_warped_spiral * 0.65 * aggressive_scale)
                        .clamp(0.05, config.thickness_of_non_warped_spiral * 0.7)
                } else {
                    (config.thickness_of_non_warped_spiral * 1.15 * aggressive_scale)
                        .clamp(0.08, config.thickness_of_non_warped_spiral * 1.3)
                };
                let _ = writeln!(
                    svg,
                    r#"  <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-linecap="round" stroke-linejoin="round"/>"#,
                    p1.0, p1.1, p2.0, p2.1, color, sw
                );
            }
            RenderItem::CrossoverStrand { p1, p2, scale, color, .. } => {
                let aggressive_scale = scale.powf(1.2);
                let sw = (config.thickness_of_non_warped_axis * 0.85 * aggressive_scale)
                    .clamp(0.2, config.thickness_of_non_warped_axis * 0.9);
                let dash1 = (1.5 * aggressive_scale).clamp(0.7, 2.0);
                let dash2 = (2.0 * aggressive_scale).clamp(0.9, 2.8);
                let _ = writeln!(
                    svg,
                    r#"  <line x1="{:.2}" y1="{:.2}" x2="{:.2}" y2="{:.2}" stroke="{}" stroke-width="{:.2}" stroke-dasharray="{:.2},{:.2}" stroke-linecap="round"/>"#,
                    p1.0, p1.1, p2.0, p2.1, color, sw, dash1, dash2
                );
            }
        }
    }

    let _ = writeln!(svg, "</svg>");
    Ok(svg.into_bytes())
}
