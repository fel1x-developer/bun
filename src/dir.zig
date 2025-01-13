const bun = @import("root").bun;
const JSC = @import("root").JavaScriptCore;
const std = @import("std");
const builtin = @import("builtin");
const FileDescriptor = bun.FileDescriptor;

pub const Dir = struct {
    fd: FileDescriptor,
};
