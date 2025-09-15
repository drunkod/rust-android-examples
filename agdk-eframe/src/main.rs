use agdk_eframe::_main;
use eframe::NativeOptions;

fn main() -> eframe::Result<()> {
    env_logger::builder()
        .filter_level(log::LevelFilter::Warn)
        .parse_default_env()
        .init();
    _main(NativeOptions::default())
}
