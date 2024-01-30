pub const webview = @import("webview");

pub fn main() !void {
    const w = webview.create(true, null);
    defer w.destroy();

    w.setTitle("wow!");
    w.navigate("https://ziglang.org/");
    w.run();
}
