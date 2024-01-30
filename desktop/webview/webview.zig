pub const c = @cImport({
    @cDefine("WEBVIEW_HEADER", "");
    @cInclude("webview.h");
});

pub const Hint = enum(i32) {
    none = 0,
    min = 1,
    max = 2,
    fixed = 3,
};

pub const Version = struct {
    major: u32,
    minor: u32,
    patch: u32,
};

pub const VersionInfo = struct {
    /// The elements of the version number.
    version: Version,
    /// SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.
    version_number: [32:0]u8,
    /// SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
    /// an empty string.
    pre_release: [48:0]u8,
    /// SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.
    build_metadata: [48:0]u8,
};

pub const Webview = opaque {
    /// Destroys a webview and closes the native window.
    pub fn destroy(w: *allowzero Webview) void {
        c.webview_destroy(w);
    }

    /// Runs the main loop until it's terminated. After this function exits - you
    /// must destroy the webview.
    pub fn run(w: *allowzero Webview) void {
        c.webview_run(w);
    }

    /// Stops the main loop. It is safe to call this function from another other
    /// background thread.
    pub fn terminate(w: *allowzero Webview) void {
        c.webview_terminate(w);
    }

    /// Posts a function to be executed on the main thread. You normally do not need
    /// to call this function, unless you want to tweak the native window.
    pub fn dispatch(
        w: *allowzero Webview,
        cb: ?*const fn (Webview, ?*anyopaque) callconv(.C) void,
        arg: ?*anyopaque,
    ) void {
        c.webview_dispatch(w, cb, arg);
    }

    /// Returns a native window handle pointer. When using a GTK backend the pointer
    /// is a GtkWindow pointer, when using a Cocoa backend the pointer is a NSWindow
    /// pointer, when using a Win32 backend the pointer is a HWND pointer.
    pub fn getWindow(w: *allowzero Webview) ?*anyopaque {
        return c.webview_get_window(w);
    }

    // Updates the title of the native window. Must be called from the UI thread.
    pub fn setTitle(w: *allowzero Webview, title: []const u8) void {
        c.webview_set_title(w, title.ptr);
    }

    /// Updates the title of the native window. Must be called from the UI thread.
    pub fn setSize(w: *allowzero Webview, width: i32, height: i32, hints: Hint) void {
        c.webview_set_size(w, width, height, @intFromEnum(hints));
    }

    /// Navigates webview to the given URL. URL may be a properly encoded data URI.
    /// Examples:
    /// webview_navigate(w, "https://github.com/webview/webview");
    /// webview_navigate(w, "data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
    /// webview_navigate(w, "data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
    pub fn navigate(w: *allowzero Webview, url: []const u8) void {
        c.webview_navigate(w, url.ptr);
    }

    /// Set webview HTML directly.
    /// Example: webview_set_html(w, "<h1>Hello</h1>");
    pub fn setHtml(w: *allowzero Webview, html: []const u8) void {
        c.webview_set_html(w, html.ptr);
    }

    /// Injects JavaScript code at the initialization of the new page. Every time
    /// the webview will open a new page - this initialization code will be
    /// executed. It is guaranteed that code is executed before window.onload.
    pub fn init(w: *allowzero Webview, js: []const u8) void {
        c.webview_init(w, js.ptr);
    }

    /// Evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
    /// the result of the expression is ignored. Use RPC bindings if you want to
    /// receive notifications about the results of the evaluation.
    pub fn eval(w: *allowzero Webview, js: []const u8) void {
        c.webview_eval(w, js.ptr);
    }

    /// Binds a native C callback so that it will appear under the given name as a
    /// global JavaScript function. Internally it uses webview_init(). The callback
    /// receives a sequential request id, a request string and a user-provided
    /// argument pointer. The request string is a JSON array of all the arguments
    /// passed to the JavaScript function.
    pub fn bind(
        w: *allowzero Webview,
        name: []const u8,
        cb: ?*const fn (seq: []const u8, req: []const u8, arg: ?*anyopaque) callconv(.C) void,
        arg: ?*anyopaque,
    ) void {
        c.webview_bind(w, name.ptr, cb, arg);
    }

    /// Removes a native C callback that was previously set by webview_bind.
    pub fn unbind(w: *allowzero Webview, name: []const u8) void {
        c.webview_unbind(w, name.ptr);
    }

    /// Responds to a binding call from the JS side. The ID/sequence number must
    /// match the value passed to the binding handler in order to respond to the
    /// call and complete the promise on the JS side. A status of zero resolves
    /// the promise, and any other value rejects it. The result must either be a
    /// valid JSON value or an empty string for the primitive JS value "undefined".
    pub fn @"return"(w: *allowzero Webview, seq: []const u8, status: i32, result: []const u8) void {
        c.webview_return(w, seq.ptr, status, result.ptr);
    }

    /// alias
    pub const _return = @"return";

    /// Get the library's version information.
    /// @since 0.10
    pub fn getVersion() VersionInfo {
        const c_version = c.webview_version();
        return .{
            .version = .{
                .major = c_version.version.major,
                .minor = c_version.version.minor,
                .patch = c_version.version.patch,
            },
            .version_number = c_version.version_number,
            .pre_release = c_version.pre_release,
            .build_metadata = c_version.build_metadata,
        };
    }
};

/// Creates a new webview instance. If debug is non-zero - developer tools will
/// be enabled (if the platform supports them). The window parameter can be a
/// pointer to the native window handle. If it's non-null - then child WebView
/// is embedded into the given parent window. Otherwise a new window is created.
/// Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
/// passed here. Returns null on failure. Creation can fail for various reasons
/// such as when required runtime dependencies are missing or when window creation
/// fails.
pub fn create(debug: bool, window: ?*anyopaque) *allowzero Webview {
    return @ptrCast(c.webview_create(if (debug) 1 else 0, window));
}
