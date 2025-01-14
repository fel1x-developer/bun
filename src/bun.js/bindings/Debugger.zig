const bun = @import("root").bun;
const jsc = bun.jsc;

pub const Debugger = struct {
    pub const AsyncCallType = enum(u8) {
        DOMTimer = 1,
        EventListener = 2,
        PostMessage = 3,
        RequestAnimationFrame = 4,
        Microtask = 5,
    };
    extern fn Debugger__didScheduleAsyncCall(*jsc.JSGlobalObject, AsyncCallType, u64, bool) void;
    extern fn Debugger__didCancelAsyncCall(*jsc.JSGlobalObject, AsyncCallType, u64) void;
    extern fn Debugger__didDispatchAsyncCall(*jsc.JSGlobalObject, AsyncCallType, u64) void;
    extern fn Debugger__willDispatchAsyncCall(*jsc.JSGlobalObject, AsyncCallType, u64) void;

    pub fn didScheduleAsyncCall(globalObject: *jsc.JSGlobalObject, call: AsyncCallType, id: u64, single_shot: bool) void {
        jsc.markBinding(@src());
        Debugger__didScheduleAsyncCall(globalObject, call, id, single_shot);
    }
    pub fn didCancelAsyncCall(globalObject: *jsc.JSGlobalObject, call: AsyncCallType, id: u64) void {
        jsc.markBinding(@src());
        Debugger__didCancelAsyncCall(globalObject, call, id);
    }
    pub fn didDispatchAsyncCall(globalObject: *jsc.JSGlobalObject, call: AsyncCallType, id: u64) void {
        jsc.markBinding(@src());
        Debugger__didDispatchAsyncCall(globalObject, call, id);
    }
    pub fn willDispatchAsyncCall(globalObject: *jsc.JSGlobalObject, call: AsyncCallType, id: u64) void {
        jsc.markBinding(@src());
        Debugger__willDispatchAsyncCall(globalObject, call, id);
    }
};
