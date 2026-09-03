use serde::Deserialize;
use std::fmt::Write as FmtWrite;
use ttf_parser::{GlyphId, OutlineBuilder};
use wasm_minimal_protocol::*;

initiate_protocol!();

// ============================================================================
// Configuration
// ============================================================================

#[derive(Deserialize)]
pub struct DiagramConfig {
    pub top_label: String,
    pub bot_label: String,
    #[serde(default = "default_top_start")]
    pub top_start: usize,
    #[serde(default = "default_top_step")]
    pub top_step: usize,
    #[serde(default = "default_bot_start")]
    pub bot_start: usize,
    #[serde(default = "default_bot_step")]
    pub bot_step: usize,
    #[serde(default = "default_rate")]
    pub rate: f32,
    #[serde(default = "default_width")]
    pub width: f32,
    #[serde(default = "default_height")]
    pub height: f32,
}

fn default_top_start() -> usize {
    1
}
fn default_top_step() -> usize {
    1
}
fn default_bot_start() -> usize {
    2
}
fn default_bot_step() -> usize {
    1
}
fn default_rate() -> f32 {
    0.00095
}
fn default_width() -> f32 {
    1000.0
}
fn default_height() -> f32 {
    240.0
}

// ============================================================================
// Perspective Projection
// ============================================================================

struct WarpProjector {
    xv: f32,
    yv: f32,
    rate: f32,
    dist: f32,
    fade_start_x: f32,
}

impl WarpProjector {
    fn new(x0: f32, xv: f32, yv: f32, rate: f32, fade_ratio: f32) -> Self {
        let dist = xv - x0;
        let fade_start_x = x0 + dist * fade_ratio;
        Self {
            xv,
            yv,
            rate,
            dist,
            fade_start_x,
        }
    }

    fn project(&self, u: f32, v: f32) -> (f32, f32) {
        let denom = 1.0 + self.rate * u;
        let x = self.xv - (self.dist / denom);
        let y = self.yv - (v / denom);
        (x, y)
    }

    fn get_scale(&self, u: f32) -> f32 {
        1.0 / (1.0 + self.rate * u)
    }

    fn get_color(&self, u: f32) -> String {
        let denom = 1.0 + self.rate * u;
        let x = self.xv - (self.dist / denom);
        if x <= self.fade_start_x {
            "rgb(0,0,0)".to_string()
        } else {
            let t = ((x - self.fade_start_x) / (self.xv - self.fade_start_x)).clamp(0.0, 1.0);
            let g = (255.0 * t.powf(0.72)).round() as u8;
            format!("rgb({g},{g},{g})")
        }
    }
}

// ============================================================================
// SVG Glyph Subdivider & Outline Builder
// ============================================================================

struct SvgSubdivider<'a> {
    projector: &'a WarpProjector,
    u_base: f32,
    v_base: f32,
    scale: f32,
    curr: (f32, f32),
    path_data: String,
}

impl<'a> SvgSubdivider<'a> {
    fn new(projector: &'a WarpProjector, u_base: f32, v_base: f32, scale: f32) -> Self {
        Self {
            projector,
            u_base,
            v_base,
            scale,
            curr: (0.0, 0.0),
            path_data: String::new(),
        }
    }

    #[inline]
    fn to_world(&self, x: f32, y: f32) -> (f32, f32) {
        (self.u_base + x * self.scale, self.v_base + y * self.scale)
    }

    #[inline]
    fn add_projected(&mut self, cmd: char, x: f32, y: f32) {
        let (wu, wv) = self.to_world(x, y);
        let (px, py) = self.projector.project(wu, wv);
        let _ = write!(self.path_data, "{cmd}{px:.2} {py:.2} ");
    }
}

impl<'a> OutlineBuilder for SvgSubdivider<'a> {
    fn move_to(&mut self, x: f32, y: f32) {
        self.curr = (x, y);
        self.add_projected('M', x, y);
    }

    fn line_to(&mut self, x: f32, y: f32) {
        let (x0, y0) = self.curr;
        let dx = x - x0;
        let dy = y - y0;
        let d = (dx * dx + dy * dy).sqrt();
        let steps = (d * self.scale / 8.0).ceil().max(1.0) as usize;
        for s in 1..=steps {
            let t = s as f32 / steps as f32;
            self.add_projected('L', x0 + dx * t, y0 + dy * t);
        }
        self.curr = (x, y);
    }

    fn quad_to(&mut self, x1: f32, y1: f32, x: f32, y: f32) {
        let (x0, y0) = self.curr;
        let steps = 6;
        for s in 1..=steps {
            let t = s as f32 / steps as f32;
            let t_inv = 1.0 - t;
            let xi = t_inv * t_inv * x0 + 2.0 * t_inv * t * x1 + t * t * x;
            let yi = t_inv * t_inv * y0 + 2.0 * t_inv * t * y1 + t * t * y;
            self.add_projected('L', xi, yi);
        }
        self.curr = (x, y);
    }

    fn curve_to(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, x: f32, y: f32) {
        let (x0, y0) = self.curr;
        let steps = 8;
        for s in 1..=steps {
            let t = s as f32 / steps as f32;
            let t_inv = 1.0 - t;
            let xi = t_inv * t_inv * t_inv * x0
                + 3.0 * t_inv * t_inv * t * x1
                + 3.0 * t_inv * t * t * x2
                + t * t * t * x;
            let yi = t_inv * t_inv * t_inv * y0
                + 3.0 * t_inv * t_inv * t * y1
                + 3.0 * t_inv * t * t * y2
                + t * t * t * y;
            self.add_projected('L', xi, yi);
        }
        self.curr = (x, y);
    }

    fn close(&mut self) {
        self.path_data.push_str("Z ");
    }
}

// ============================================================================
// Font Handling (TTF Parsing, Shaping, Number Formatting & Glyph Rendering)
// ============================================================================

struct LoadedFont<'a> {
    ttf: ttf_parser::Face<'a>,
    rb: rustybuzz::Face<'a>,
    scale: f32,
}

impl<'a> LoadedFont<'a> {
    fn from_bytes(bytes: &'a [u8], font_pt: f32, name: &str) -> Result<Self, String> {
        let ttf = ttf_parser::Face::parse(bytes, 0)
            .map_err(|e| format!("{name} TTF parse error: {e:?}"))?;
        let rb = rustybuzz::Face::from_slice(bytes, 0)
            .ok_or_else(|| format!("{name} RustyBuzz load error"))?;
        let scale = font_pt / ttf.units_per_em() as f32;
        Ok(Self { ttf, rb, scale })
    }

    fn shape_and_measure(&self, text: &str) -> (Vec<(u32, f32, f32, f32)>, f32) {
        let mut buffer = rustybuzz::UnicodeBuffer::new();
        buffer.push_str(text);
        let shaped = rustybuzz::shape(&self.rb, &[], buffer);
        let infos = shaped.glyph_infos();
        let positions = shaped.glyph_positions();

        let mut glyphs = Vec::with_capacity(infos.len());
        let mut cursor = 0.0;
        for (info, pos) in infos.iter().zip(positions.iter()) {
            let x_offset = cursor + (pos.x_offset as f32 * self.scale);
            let y_offset = pos.y_offset as f32 * self.scale;
            let advance = pos.x_advance as f32 * self.scale;
            glyphs.push((info.glyph_id, x_offset, y_offset, advance));
            cursor += advance;
        }
        (glyphs, cursor)
    }

    /// Converts a number to string, mapping ASCII digits to script-specific digits (e.g. Khmer)
    /// if the font lacks ASCII digits but has script digits.
    fn format_number(&self, val: usize) -> String {
        let s = val.to_string();
        if self.ttf.glyph_index('1').is_none() && self.ttf.glyph_index('\u{17e1}').is_some() {
            s.chars()
                .map(|c| {
                    if c.is_ascii_digit() {
                        char::from_u32(c as u32 + 0x17b0).unwrap_or(c)
                    } else {
                        c
                    }
                })
                .collect()
        } else {
            s
        }
    }

    fn render_glyphs(
        &self,
        svg: &mut String,
        glyphs: &[(u32, f32, f32, f32)],
        projector: &WarpProjector,
        u_base: f32,
        v_base: f32,
    ) {
        for &(gid, x_off, y_off, _) in glyphs {
            let mut builder =
                SvgSubdivider::new(projector, u_base + x_off, v_base + y_off, self.scale);
            if let Some(_bbox) = self.ttf.outline_glyph(GlyphId(gid as u16), &mut builder) {
                let color = projector.get_color(u_base + x_off);
                let _ = writeln!(
                    svg,
                    r#"<path fill="{color}" d="{pd}"/>"#,
                    pd = builder.path_data
                );
            }
        }
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

#[wasm_func]
pub fn render(
    font_top_bytes: &[u8],
    font_bot_bytes: &[u8],
    config_bytes: &[u8],
) -> Result<Vec<u8>, String> {
    render_internal(font_top_bytes, font_bot_bytes, config_bytes)
}

fn render_internal(
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

// ============================================================================
// Gene Spiral (Double Helix Perspective Diagram)
// ============================================================================

#[derive(Deserialize, Debug)]
pub struct GeneSpiralConfig {
    #[serde(default = "default_spiral_width")]
    pub width: f32,
    #[serde(default = "default_spiral_height")]
    pub height: f32,
    #[serde(default = "default_start_x")]
    pub start_x: f32,
    #[serde(default = "default_start_y")]
    pub start_y: f32,
    #[serde(default = "default_vanish_x")]
    pub vanish_x: f32,
    #[serde(default = "default_vanish_y")]
    pub vanish_y: f32,
    #[serde(default = "default_radius_x")]
    pub radius_x: f32,
    #[serde(default = "default_radius_y")]
    pub radius_y: f32,
    #[serde(default = "default_nodes_per_turn")]
    pub nodes_per_turn: usize,
    #[serde(default = "default_num_turns")]
    pub num_turns: usize,
    #[serde(default = "default_spiral_rate")]
    pub rate: f32,
    #[serde(default = "default_pitch")]
    pub pitch: f32,
    #[serde(default = "default_theta_offset")]
    pub theta_offset_deg: f32,
    #[serde(default = "default_tilt_deg")]
    pub tilt_deg: f32,
    #[serde(default = "default_black_color")]
    pub black_color: String,
    #[serde(default = "default_gray_color")]
    pub gray_color: String,
    #[serde(default = "default_spoke_color")]
    pub spoke_color: String,
    #[serde(default = "default_axis_color")]
    pub axis_color: String,
    #[serde(default = "default_draw_axis")]
    pub draw_axis: bool,
    #[serde(default = "default_stroke_base")]
    pub stroke_base: f32,
    #[serde(default = "default_draw_cross_rings")]
    pub draw_cross_rings: bool,
    #[serde(default = "default_gap")]
    pub gap: f32,
}

fn default_gap() -> f32 {
    0.0
}

fn default_spiral_width() -> f32 {
    266.0
}
fn default_spiral_height() -> f32 {
    210.0
}
fn default_start_x() -> f32 {
    35.0
}
fn default_start_y() -> f32 {
    118.0
}
fn default_vanish_x() -> f32 {
    245.0
}
fn default_vanish_y() -> f32 {
    55.0
}
fn default_radius_x() -> f32 {
    52.0
}
fn default_radius_y() -> f32 {
    68.0
}
fn default_nodes_per_turn() -> usize {
    8
}
fn default_num_turns() -> usize {
    60
}
fn default_spiral_rate() -> f32 {
    0.0042
}
fn default_pitch() -> f32 {
    26.0
}
fn default_theta_offset() -> f32 {
    -70.0
}
fn default_tilt_deg() -> f32 {
    -10.0
}
fn default_black_color() -> String {
    "#16181b".to_string()
}
fn default_gray_color() -> String {
    "#8b9097".to_string()
}
fn default_spoke_color() -> String {
    "#686d75".to_string()
}
fn default_axis_color() -> String {
    "rgba(130, 135, 142, 0.6)".to_string()
}
fn default_draw_axis() -> bool {
    true
}
fn default_stroke_base() -> f32 {
    2.4
}
fn default_draw_cross_rings() -> bool {
    false
}

#[wasm_func]
pub fn render_gene_spiral(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    render_gene_spiral_internal(config_bytes)
}

pub fn render_gene_spiral_internal(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let config: GeneSpiralConfig = if config_bytes.is_empty() {
        serde_json::from_str("{}").map_err(|e| e.to_string())?
    } else {
        serde_json::from_slice(config_bytes).map_err(|e| e.to_string())?
    };
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

    // Scale function s(u) = 1 / (1 + rate * u)
    let get_scale = |u: f32| -> f32 { 1.0 / (1.0 + config.rate * u) };

    // Center in 2D for parameter u
    let get_center = |u: f32| -> (f32, f32) {
        let s = get_scale(u);
        let cx = config.vanish_x - (config.vanish_x - config.start_x) * s;
        let cy = config.vanish_y - (config.vanish_y - config.start_y) * s;
        (cx, cy)
    };

    // 3D point projected to 2D
    let get_projected_point = |u: f32, theta: f32| -> ((f32, f32), f32) {
        let s = get_scale(u);
        let (cx, cy) = get_center(u);
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
        let (x0, y0) = get_center(0.0);
        let (xv, yv) = (config.vanish_x, config.vanish_y);
        let _ = writeln!(
            svg,
            r#"    <line x1="{x0:.2}" y1="{y0:.2}" x2="{xv:.2}" y2="{yv:.2}" stroke="{}" stroke-width="0.75" stroke-dasharray="2.5,3.5" stroke-linecap="round"/>"#,
            config.axis_color
        );
    }

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

    // Build nodes for Spiral A (Black)
    // and Spiral B (Gray), with aligned theta angles
    let mut nodes_a: Vec<SpiralNode> = Vec::with_capacity(512);
    let mut nodes_b: Vec<SpiralNode> = Vec::with_capacity(512);

    let mut m = 0;
    while m < 10000 {
        let theta = theta_0 + m as f32 * theta_step;

        // Spiral A: at u_a
        let u_a = m as f32 * step_u;
        let s_a = get_scale(u_a);
        let (cx_a, _) = get_center(u_a);

        if cx_a >= config.vanish_x - 1.0 || s_a < 0.012 {
            break;
        }

        let (pt_a, depth_a) = get_projected_point(u_a, theta);
        let c_a = get_center(u_a);
        nodes_a.push(SpiralNode {
            pt: pt_a,
            depth: depth_a,
            scale: s_a,
            center: c_a,
        });

        // Spiral B: shifted by gap along axis, aligned in theta
        let u_b = u_a + gap;
        let s_b = get_scale(u_b);
        let (cx_b, _) = get_center(u_b);

        if cx_b < config.vanish_x - 1.0 && s_b >= 0.012 {
            let (pt_b, depth_b) = get_projected_point(u_b, theta);
            let c_b = get_center(u_b);
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
