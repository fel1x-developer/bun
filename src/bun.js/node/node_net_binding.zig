const std = @import("std");
const bun = @import("root").bun;
const Environment = bun.Environment;
const jsc = bun.jsc;
const string = bun.string;
const Output = bun.Output;
const ZigString = jsc.ZigString;

//
//

pub var autoSelectFamilyDefault: bool = true;

pub fn getDefaultAutoSelectFamily(global: *jsc.JSGlobalObject) jsc.JSValue {
    return jsc.JSFunction.create(global, "getDefaultAutoSelectFamily", (struct {
        fn getter(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
            _ = globalThis;
            _ = callframe;
            return jsc.jsBoolean(autoSelectFamilyDefault);
        }
    }).getter, 0, .{});
}

pub fn setDefaultAutoSelectFamily(global: *jsc.JSGlobalObject) jsc.JSValue {
    return jsc.JSFunction.create(global, "setDefaultAutoSelectFamily", (struct {
        fn setter(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
            const arguments = callframe.arguments_old(1);
            if (arguments.len < 1) {
                return globalThis.throw("missing argument", .{});
            }
            const arg = arguments.slice()[0];
            if (!arg.isBoolean()) {
                return globalThis.throwInvalidArguments("autoSelectFamilyDefault", .{});
            }
            const value = arg.toBoolean();
            autoSelectFamilyDefault = value;
            return jsc.jsBoolean(value);
        }
    }).setter, 1, .{});
}

//
//

pub var autoSelectFamilyAttemptTimeoutDefault: u32 = 250;

pub fn getDefaultAutoSelectFamilyAttemptTimeout(global: *jsc.JSGlobalObject) jsc.JSValue {
    return jsc.JSFunction.create(global, "getDefaultAutoSelectFamilyAttemptTimeout", (struct {
        fn getter(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
            _ = globalThis;
            _ = callframe;
            return jsc.jsNumber(autoSelectFamilyAttemptTimeoutDefault);
        }
    }).getter, 0, .{});
}

pub fn setDefaultAutoSelectFamilyAttemptTimeout(global: *jsc.JSGlobalObject) jsc.JSValue {
    return jsc.JSFunction.create(global, "setDefaultAutoSelectFamilyAttemptTimeout", (struct {
        fn setter(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
            const arguments = callframe.arguments_old(1);
            if (arguments.len < 1) {
                return globalThis.throw("missing argument", .{});
            }
            const arg = arguments.slice()[0];
            if (!arg.isInt32AsAnyInt()) {
                return globalThis.throwInvalidArguments("autoSelectFamilyAttemptTimeoutDefault", .{});
            }
            const value: u32 = @max(10, arg.coerceToInt32(globalThis));
            autoSelectFamilyAttemptTimeoutDefault = value;
            return jsc.jsNumber(value);
        }
    }).setter, 1, .{});
}
