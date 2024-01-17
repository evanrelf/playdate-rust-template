#![no_std]

extern crate alloc;

use alloc::boxed::Box;
use crankstart::{crankstart_game, graphics::Graphics, system::System, Game, Playdate};
use euclid::Point2D;

const SCREEN_WIDTH: i32 = 400;
const SCREEN_HEIGHT: i32 = 240;

struct State {
    fps: bool,
}

impl State {
    fn new(_playdate: &mut Playdate) -> anyhow::Result<Box<Self>> {
        let state = Self { fps: true };

        Ok(Box::new(state))
    }
}

impl Game for State {
    fn update(&mut self, _playdate: &mut Playdate) -> anyhow::Result<()> {
        if self.fps {
            let system = System::get();
            system.draw_fps(0, 0)?;
        }

        let graphics = Graphics::get();
        graphics.draw_text(
            "Hello, world!",
            Point2D::new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2),
        )?;

        Ok(())
    }
}

crankstart_game!(State);
