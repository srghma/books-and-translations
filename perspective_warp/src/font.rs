use std::fmt::Write as FmtWrite;
use ttf_parser::{GlyphId, OutlineBuilder};

// ============================================================================
// Glyph Projection Interface
// ============================================================================

pub trait GlyphProjector {
    fn project(&self, u: f32, v: f32) -> (f32, f32);
    fn get_color(&self, u: f32) -> String;
}

// ============================================================================
// SVG Glyph Subdivider & Outline Builder
// ============================================================================

pub struct SvgSubdivider<'a, P: GlyphProjector> {
    projector: &'a P,
    u_base: f32,
    v_base: f32,
    scale: f32,
    curr: (f32, f32),
    pub path_data: String,
}

impl<'a, P: GlyphProjector> SvgSubdivider<'a, P> {
    pub fn new(projector: &'a P, u_base: f32, v_base: f32, scale: f32) -> Self {
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

impl<'a, P: GlyphProjector> OutlineBuilder for SvgSubdivider<'a, P> {
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
// Font Loading, Shaping, Localization & Rendering
// ============================================================================

pub struct LoadedFont<'a> {
    pub ttf: ttf_parser::Face<'a>,
    pub rb: rustybuzz::Face<'a>,
    pub scale: f32,
}

impl<'a> LoadedFont<'a> {
    pub fn from_bytes(bytes: &'a [u8], font_pt: f32, name: &str) -> Result<Self, String> {
        let ttf = ttf_parser::Face::parse(bytes, 0)
            .map_err(|e| format!("{name} TTF parse error: {e:?}"))?;
        let rb = rustybuzz::Face::from_slice(bytes, 0)
            .ok_or_else(|| format!("{name} RustyBuzz load error"))?;
        let scale = font_pt / ttf.units_per_em() as f32;
        Ok(Self { ttf, rb, scale })
    }

    pub fn shape_and_measure(&self, text: &str) -> (Vec<(u32, f32, f32, f32)>, f32) {
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
    pub fn format_number(&self, val: usize) -> String {
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

    pub fn render_glyphs<P: GlyphProjector>(
        &self,
        svg: &mut String,
        glyphs: &[(u32, f32, f32, f32)],
        projector: &P,
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
