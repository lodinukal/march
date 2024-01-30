const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const webview = b.dependency("webview", .{});

    const exe = b.addExecutable(.{
        .name = "march",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{
            .path = "src/main.zig",
        },
    });
    // b.installDirectory(options: Step.InstallDir.Options)
    exe.root_module.addImport("webview", webview.module("webview"));
    b.installArtifact(exe);
}
