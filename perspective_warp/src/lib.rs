use wasm_minimal_protocol::*;

initiate_protocol!();

pub mod common;
pub mod font;
pub mod perspective_diagram;
pub mod spiral;

pub use perspective_diagram::DiagramConfig;
pub use spiral::GeneSpiralConfig;

#[wasm_func]
pub fn render(
    font_top_bytes: &[u8],
    font_bot_bytes: &[u8],
    config_bytes: &[u8],
) -> Result<Vec<u8>, String> {
    perspective_diagram::render(font_top_bytes, font_bot_bytes, config_bytes)
}

#[wasm_func]
pub fn render_gene_spiral(config_bytes: &[u8]) -> Result<Vec<u8>, String> {
    spiral::render(config_bytes)
}
