const std = @import("std");
const bun = @import("root").bun;
const Environment = bun.Environment;
const jsc = bun.jsc;
const string = bun.string;
const Output = bun.Output;
const ZigString = jsc.ZigString;
const createTypeError = jsc.JSGlobalObject.createTypeErrorInstanceWithCode;
const createError = jsc.JSGlobalObject.createErrorInstanceWithCode;
const createRangeError = jsc.JSGlobalObject.createRangeErrorInstanceWithCode;

pub const ERR_INVALID_HANDLE_TYPE = createSimpleError(createTypeError, .ERR_INVALID_HANDLE_TYPE, "This handle type cannot be sent");
pub const ERR_CHILD_CLOSED_BEFORE_REPLY = createSimpleError(createError, .ERR_CHILD_CLOSED_BEFORE_REPLY, "Child closed before reply received");

fn createSimpleError(comptime createFn: anytype, comptime code: jsc.Node.ErrorCode, comptime message: string) jsc.JS2NativeFunctionType {
    const R = struct {
        pub fn cbb(global: *jsc.JSGlobalObject) bun.JSError!jsc.JSValue {
            const S = struct {
                fn cb(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
                    _ = callframe;
                    return createFn(globalThis, code, message, .{});
                }
            };
            return jsc.JSFunction.create(global, @tagName(code), S.cb, 0, .{});
        }
    };
    return R.cbb;
}
