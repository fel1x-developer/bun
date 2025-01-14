const bun = @import("root").bun;
const logger = bun.logger;
const std = @import("std");
const Fs = bun.fs;
const string = bun.string;
const Resolver = @import("../resolver//resolver.zig").Resolver;
const jsc = bun.jsc;
const JSGlobalObject = jsc.JSGlobalObject;
const strings = bun.strings;
const default_allocator = bun.default_allocator;
const ZigString = jsc.ZigString;
const JSValue = jsc.JSValue;

pub const BuildMessage = struct {
    msg: logger.Msg,
    // resolve_result: Resolver.Result,
    allocator: std.mem.Allocator,
    logged: bool = false,

    pub usingnamespace jsc.Codegen.JSBuildMessage;

    pub fn constructor(globalThis: *jsc.JSGlobalObject, _: *jsc.CallFrame) bun.JSError!*BuildMessage {
        return globalThis.throw("BuildMessage is not constructable", .{});
    }

    pub fn getNotes(this: *BuildMessage, globalThis: *jsc.JSGlobalObject) jsc.JSValue {
        const notes = this.msg.notes;
        const array = jsc.JSValue.createEmptyArray(globalThis, notes.len);
        for (notes, 0..) |note, i| {
            const cloned = note.clone(bun.default_allocator) catch {
                return globalThis.throwOutOfMemoryValue();
            };
            array.putIndex(
                globalThis,
                @intCast(i),
                BuildMessage.create(globalThis, bun.default_allocator, logger.Msg{ .data = cloned, .kind = .note }),
            );
        }

        return array;
    }

    pub fn toStringFn(this: *BuildMessage, globalThis: *jsc.JSGlobalObject) jsc.JSValue {
        const text = std.fmt.allocPrint(default_allocator, "BuildMessage: {s}", .{this.msg.data.text}) catch {
            return globalThis.throwOutOfMemoryValue();
        };
        var str = ZigString.init(text);
        str.setOutputEncoding();
        if (str.isUTF8()) {
            const out = str.toJS(globalThis);
            default_allocator.free(text);
            return out;
        }

        return str.toExternalValue(globalThis);
    }

    pub fn create(
        globalThis: *jsc.JSGlobalObject,
        allocator: std.mem.Allocator,
        msg: logger.Msg,
        // resolve_result: *const Resolver.Result,
    ) jsc.JSValue {
        var build_error = allocator.create(BuildMessage) catch unreachable;
        build_error.* = BuildMessage{
            .msg = msg.clone(allocator) catch unreachable,
            // .resolve_result = resolve_result.*,
            .allocator = allocator,
        };

        return build_error.toJS(globalThis);
    }

    pub fn toString(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
        _: *jsc.CallFrame,
    ) bun.JSError!jsc.JSValue {
        return this.toStringFn(globalThis);
    }

    pub fn toPrimitive(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
        callframe: *jsc.CallFrame,
    ) bun.JSError!jsc.JSValue {
        const args_ = callframe.arguments_old(1);
        const args = args_.ptr[0..args_.len];
        if (args.len > 0) {
            if (!args[0].isString()) {
                return jsc.JSValue.jsNull();
            }

            const str = args[0].getZigString(globalThis);
            if (str.eqlComptime("default") or str.eqlComptime("string")) {
                return this.toStringFn(globalThis);
            }
        }

        return jsc.JSValue.jsNull();
    }

    pub fn toJSON(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
        _: *jsc.CallFrame,
    ) bun.JSError!jsc.JSValue {
        var object = jsc.JSValue.createEmptyObject(globalThis, 4);
        object.put(globalThis, ZigString.static("name"), bun.String.static("BuildMessage").toJS(globalThis));
        object.put(globalThis, ZigString.static("position"), this.getPosition(globalThis));
        object.put(globalThis, ZigString.static("message"), this.getMessage(globalThis));
        object.put(globalThis, ZigString.static("level"), this.getLevel(globalThis));
        return object;
    }

    pub fn generatePositionObject(msg: logger.Msg, globalThis: *jsc.JSGlobalObject) jsc.JSValue {
        const location = msg.data.location orelse return jsc.JSValue.jsNull();
        var object = jsc.JSValue.createEmptyObject(globalThis, 7);

        object.put(
            globalThis,
            ZigString.static("lineText"),
            ZigString.init(location.line_text orelse "").toJS(globalThis),
        );
        object.put(
            globalThis,
            ZigString.static("file"),
            ZigString.init(location.file).toJS(globalThis),
        );
        object.put(
            globalThis,
            ZigString.static("namespace"),
            ZigString.init(location.namespace).toJS(globalThis),
        );
        object.put(
            globalThis,
            ZigString.static("line"),
            JSValue.jsNumber(location.line),
        );
        object.put(
            globalThis,
            ZigString.static("column"),
            JSValue.jsNumber(location.column),
        );
        object.put(
            globalThis,
            ZigString.static("length"),
            JSValue.jsNumber(location.length),
        );
        object.put(
            globalThis,
            ZigString.static("offset"),
            JSValue.jsNumber(location.offset),
        );

        return object;
    }

    // https://github.com/oven-sh/bun/issues/2375#issuecomment-2121530202
    pub fn getColumn(this: *BuildMessage, _: *jsc.JSGlobalObject) jsc.JSValue {
        if (this.msg.data.location) |location| {
            return jsc.JSValue.jsNumber(@max(location.column - 1, 0));
        }

        return jsc.JSValue.jsNumber(@as(i32, 0));
    }

    pub fn getLine(this: *BuildMessage, _: *jsc.JSGlobalObject) jsc.JSValue {
        if (this.msg.data.location) |location| {
            return jsc.JSValue.jsNumber(@max(location.line - 1, 0));
        }

        return jsc.JSValue.jsNumber(@as(i32, 0));
    }

    pub fn getPosition(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
    ) jsc.JSValue {
        return BuildMessage.generatePositionObject(this.msg, globalThis);
    }

    pub fn getMessage(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
    ) jsc.JSValue {
        return ZigString.init(this.msg.data.text).toJS(globalThis);
    }

    pub fn getLevel(
        this: *BuildMessage,
        globalThis: *jsc.JSGlobalObject,
    ) jsc.JSValue {
        return ZigString.init(this.msg.kind.string()).toJS(globalThis);
    }

    pub fn finalize(this: *BuildMessage) void {
        this.msg.deinit(bun.default_allocator);
    }
};
