pub usingnamespace @import("./src/main.zig");

/// These functions are used throughout Bun's codebase.
pub const Bun = @import("./src/Bun.zig");

pub const Completions = struct {
    pub const bash = @embedFile("./completions/bun.bash");
    pub const zsh = @embedFile("./completions/bun.zsh");
    pub const fish = @embedFile("./completions/bun.fish");
};

pub const JavaScriptCore = @import("./src/JSC.zig");
pub const C = @import("./src/c.zig");
