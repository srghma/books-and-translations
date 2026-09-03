// ============================================================================
// Common Perspective & Geometry Utilities
// ============================================================================

/// Computes the perspective scale factor s(u) = 1 / (1 + rate * u)
#[inline]
pub fn perspective_scale(rate: f32, u: f32) -> f32 {
    1.0 / (1.0 + rate * u)
}

/// A 2D perspective axis defined by a start point, a vanishing point, and a recession rate.
#[derive(Debug, Clone, Copy)]
pub struct PerspectiveCamera {
    pub start_x: f32,
    pub start_y: f32,
    pub vanish_x: f32,
    pub vanish_y: f32,
    pub rate: f32,
}

impl PerspectiveCamera {
    pub fn new(start_x: f32, start_y: f32, vanish_x: f32, vanish_y: f32, rate: f32) -> Self {
        Self {
            start_x,
            start_y,
            vanish_x,
            vanish_y,
            rate,
        }
    }

    #[inline]
    pub fn scale(&self, u: f32) -> f32 {
        perspective_scale(self.rate, u)
    }

    /// Evaluates the 2D position of the central perspective axis at distance `u`.
    #[inline]
    pub fn axis_point(&self, u: f32) -> (f32, f32) {
        let s = self.scale(u);
        let x = self.vanish_x - (self.vanish_x - self.start_x) * s;
        let y = self.vanish_y - (self.vanish_y - self.start_y) * s;
        (x, y)
    }
}

/// Formats a grayscale color fading from black to white with gamma correction.
#[inline]
pub fn fade_grayscale(t: f32, gamma: f32) -> String {
    let t_clamped = t.clamp(0.0, 1.0);
    let g = (255.0 * t_clamped.powf(gamma)).round() as u8;
    format!("rgb({g},{g},{g})")
}
