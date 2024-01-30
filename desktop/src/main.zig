const std = @import("std");
const webview = @import("webview");

const relative_to_cwd = "../frontend/site/build/";

pub fn main() !void {
    const w = webview.create(true, null);
    defer w.destroy();

    w.setTitle("wow!");
    w.setVirtualHostName("", relative_to_cwd);
    w.run();
}
