const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const webview_static = b.addStaticLibrary(.{
        .name = "__webview_static",
        .target = target,
        .optimize = optimize,
    });
    webview_static.addIncludePath(.{
        .path = ".",
    });
    webview_static.addCSourceFile(.{
        .file = .{ .path = "webview.cpp" },
    });
    webview_static.linkLibCpp();

    if (target.result.os.tag == .windows) {
        webview_static.addIncludePath(.{
            .path = "webview2/build/native/include",
        });
        webview_static.linkSystemLibrary("advapi32");
        webview_static.linkSystemLibrary("ole32");
        webview_static.linkSystemLibrary("shell32");
        webview_static.linkSystemLibrary("shlwapi");
        webview_static.linkSystemLibrary("user32");
        webview_static.linkSystemLibrary("version");
    } else if (target.result.os.tag == .macos) {
        webview_static.linkFramework("WebKit");
    }

    const webview = b.addModule("webview", .{
        .root_source_file = .{
            .path = "webview.zig",
        },
        .target = target,
        .optimize = optimize,
    });
    webview.linkLibrary(webview_static);
    webview.addIncludePath(.{
        .path = ".",
    });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{
            .path = "example.zig",
        },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("webview", webview);
    exe.linkLibrary(webview_static);
    const example_step = b.step("example", "Builds the webview.h example");
    example_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
    const run_step = b.step("run-example", "Runs the webview.h example");
    run_step.dependOn(&b.addRunArtifact(exe).step);
}
