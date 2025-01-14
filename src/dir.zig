const bun = @import("root").bun;
const jsc = bun.jsc;
const std = @import("std");
const builtin = @import("builtin");
const FileDescriptor = bun.FileDescriptor;

pub const Dir = struct {
    fd: FileDescriptor,
};
