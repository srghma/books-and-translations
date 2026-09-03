use crate::common::{fade_grayscale, PerspectiveCamera};
use crate::font::{GlyphProjector, LoadedFont};
use serde::Deserialize;
use std::fmt::Write as FmtWrite;

// ============================================================================
// Configuration
// ============================================================================

#[derive(Deserialize)]
pub struct DiagramConfig {
    pub top_label: String,
    pub bot_label: String,
    pub top_start: usize,
    pub top_step: usize,
    pub bot_start: usize,
    pub bot_step: usize,
    pub rate: f32,
    pub width: f32,
    pub height: f32,
}

// ============================================================================
// Perspective Projection
// ============================================================================

pub struct WarpProjector {
    pub camera: PerspectiveCamera,
    pub fade_start_x: f32,
}

impl WarpProjector {
    pub fn new(x0: f32, xv: f32, yv: f32, rate: f32, fade_ratio: f32) -> Self {
        let dist = xv - x0;
        let fade_start_x = x0 + dist * fade_ratio;
        Self {
            camera: PerspectiveCamera::new(x0, yv, xv, yv, rate),
            fade_start_x,
        }
    }

    #[inline]
    pub fn project(&self, u: f32, v: f32) -> (f32, f32) {
        let s = self.camera.scale(u);
        let x = self.camera.vanish_x - (self.camera.vanish_x - self.camera.start_x) * s;
        let y = self.camera.vanish_y - v * s;
        (x, y)
    }

    #[inline]
    pub fn get_scale(&self, u: f32) -> f32 {
        self.camera.scale(u)
    }

    pub fn get_color(&self, u: f32) -> String {
        let s = self.camera.scale(u);
        let x = self.camera.vanish_x - (self.camera.vanish_x - self.camera.start_x) * s;
        if x <= self.fade_start_x {
            "rgb(0,0,0)".to_string()
        } else {
            let t = (x - self.fade_start_x) / (self.camera.vanish_x - self.fade_start_x);
            fade_grayscale(t, 0.72)
        }
    }
}

impl GlyphProjector for WarpProjector {
    fn project(&self, u: f32, v: f32) -> (f32, f32) {
        self.project(u, v)
    }

    fn get_color(&self, u: f32) -> String {
        self.get_color(u)
    }
}

// ============================================================================
// Arrow Geometry Rendering
// ============================================================================

fn render_polygon(svg: &mut String, projector: &WarpProjector, pts: &[(f32, f32)], color_u: f32) {
    let color = projector.get_color(color_u);
    svg.push_str("<polygon fill=\"");
    svg.push_str(&color);
    svg.push_str("\" points=\"");
    for (i, &(pu, pv)) in pts.iter().enumerate() {
        let (px, py) = projector.project(pu, pv);
        if i > 0 {
            svg.push(' ');
        }
        let _ = write!(svg, "{px:.2},{py:.2}");
    }
    svg.push_str("\"/>\n");
}

fn draw_bold_right_arrow(
    svg: &mut String,
    projector: &WarpProjector,
    u_start: f32,
    v_center: f32,
    length: f32,
    thickness: f32,
    head_size: f32,
) {
    let u_end = u_start + length;
    let u_shaft_end = u_end - head_size;
    let half_th = thickness / 2.0;

    let pts = [
        (u_start, v_center - half_th),
        (u_shaft_end, v_center - half_th),
        (u_shaft_end, v_center - head_size * 0.95),
        (u_end, v_center),
        (u_shaft_end, v_center + head_size * 0.95),
        (u_shaft_end, v_center + half_th),
        (u_start, v_center + half_th),
    ];

    render_polygon(svg, projector, &pts, u_start);
}

fn draw_vertical_double_arrow(
    svg: &mut String,
    projector: &WarpProjector,
    u: f32,
    v_top: f32,
    v_bot: f32,
    thickness: f32,
    head_sz: f32,
) {
    let half_th = thickness / 2.0;
    let v_shaft_top = v_top - head_sz;
    let v_shaft_bot = v_bot + head_sz;

    let pts = [
        (u, v_top),
        (u + head_sz * 0.65, v_shaft_top),
        (u + half_th, v_shaft_top),
        (u + half_th, v_shaft_bot),
        (u + head_sz * 0.65, v_shaft_bot),
        (u, v_bot),
        (u - head_sz * 0.65, v_shaft_bot),
        (u - half_th, v_shaft_bot),
        (u - half_th, v_shaft_top),
        (u - head_sz * 0.65, v_shaft_top),
    ];

    render_polygon(svg, projector, &pts, u);
}

// ============================================================================
// Main Diagram Renderer
// ============================================================================

pub fn render(
    font_top_bytes: &[u8],
    font_bot_bytes: &[u8],
    config_bytes: &[u8],
) -> Result<Vec<u8>, String> {
    let config: DiagramConfig =
        serde_json::from_slice(config_bytes).map_err(|e| format!("Invalid JSON config: {e}"))?;

    let font_pt = 66.0;
    let font_top = LoadedFont::from_bytes(font_top_bytes, font_pt, "Font Top")?;
    let font_bot_owned = if font_bot_bytes.is_empty() || font_bot_bytes == font_top_bytes {
        None
    } else {
        Some(LoadedFont::from_bytes(
            font_bot_bytes,
            font_pt,
            "Font Bottom",
        )?)
    };
    let font_bot = font_bot_owned.as_ref().unwrap_or(&font_top);

    let w = config.width;
    let h = config.height;
    let xv = w - 24.0;
    let x0 = 18.0;
    let yv = h / 2.0;

    // Baselines in Euclidean (u, v) space
    let v_top = 46.0;
    let v_bot = -46.0;

    let projector = WarpProjector::new(x0, xv, yv, config.rate, 0.52);

    let mut svg = String::with_capacity(256 * 1024);
    let _ = write!(
        svg,
        r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">"#
    );
    svg.push('\n');

    // 1. Measure and render labels
    let (glyphs_top, len_top) = font_top.shape_and_measure(&config.top_label);
    let (glyphs_bot, len_bot) = font_bot.shape_and_measure(&config.bot_label);

    let max_len = len_top.max(len_bot);
    let arrow_len = 50.0;
    let arrow_th = 12.0;
    let arrow_head = 22.0;
    let gap_after_text = 18.0;
    let gap_after_arrow = 32.0;

    let u_arrow_start = max_len + gap_after_text;
    let u_arrow_end = u_arrow_start + arrow_len;
    let u_numbers_start = u_arrow_end + gap_after_arrow;

    let u_top_start = 0.0;
    let u_bot_start = max_len - len_bot;

    font_top.render_glyphs(&mut svg, &glyphs_top, &projector, u_top_start, v_top);
    font_bot.render_glyphs(&mut svg, &glyphs_bot, &projector, u_bot_start, v_bot);

    // 2. Render horizontal right arrows (➔)
    let v_arr_top = v_top + 18.0;
    let v_arr_bot = v_bot + 18.0;
    draw_bold_right_arrow(
        &mut svg,
        &projector,
        u_arrow_start,
        v_arr_top,
        arrow_len,
        arrow_th,
        arrow_head,
    );
    draw_bold_right_arrow(
        &mut svg,
        &projector,
        u_arrow_start,
        v_arr_bot,
        arrow_len,
        arrow_th,
        arrow_head,
    );

    // 3. Render receding numbers and vertical double-headed arrows
    let num_step = 70.0;
    let v_double_arrow_top = v_top - 8.0;
    let v_double_arrow_bot = v_bot + 44.0;
    let double_arr_th = 4.2;
    let double_arr_head = 10.5;

    let max_k = 250;
    for k in 0..max_k {
        let u_col = u_numbers_start + k as f32 * num_step;
        let sc = projector.get_scale(u_col);
        let (px_col, _) = projector.project(u_col, 0.0);

        // Terminate at vanishing point
        if px_col >= xv - 0.8 {
            break;
        }

        let color = projector.get_color(u_col);

        // While numbers are large enough to be discernible (sc > 0.10)
        if sc > 0.10 {
            let s_top = font_top.format_number(config.top_start + k * config.top_step);
            let s_bot = font_bot.format_number(config.bot_start + k * config.bot_step);

            let (g_top, width_top) = font_top.shape_and_measure(&s_top);
            let (g_bot, width_bot) = font_bot.shape_and_measure(&s_bot);

            font_top.render_glyphs(&mut svg, &g_top, &projector, u_col - width_top / 2.0, v_top);
            font_bot.render_glyphs(&mut svg, &g_bot, &projector, u_col - width_bot / 2.0, v_bot);

            draw_vertical_double_arrow(
                &mut svg,
                &projector,
                u_col,
                v_double_arrow_top,
                v_double_arrow_bot,
                double_arr_th,
                double_arr_head,
            );
        } else {
            // As columns recede into distance, numbers and arrow merge into a unified fine tick
            let (px, py_top) = projector.project(u_col, (v_top + 28.0) * 0.94);
            let (_, py_bot) = projector.project(u_col, (v_bot - 10.0) * 0.94);
            let stroke_w = (1.4 * sc).clamp(0.25, 0.75);
            let _ = writeln!(
                svg,
                r#"<line x1="{px:.2}" y1="{py_top:.2}" x2="{px:.2}" y2="{py_bot:.2}" stroke="{color}" stroke-width="{stroke_w:.2}"/>"#
            );
        }
    }

    svg.push_str("</svg>");
    Ok(svg.into_bytes())
}
