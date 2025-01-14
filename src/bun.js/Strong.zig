const bun = @import("root").bun;
const jsc = bun.jsc;

const StrongImpl = opaque {
    pub fn init(globalThis: *jsc.JSGlobalObject, value: jsc.JSValue) *StrongImpl {
        jsc.markBinding(@src());
        return Bun__StrongRef__new(globalThis, value);
    }

    pub fn get(this: *StrongImpl) jsc.JSValue {
        jsc.markBinding(@src());
        return Bun__StrongRef__get(this);
    }

    pub fn set(this: *StrongImpl, globalThis: *jsc.JSGlobalObject, value: jsc.JSValue) void {
        jsc.markBinding(@src());
        Bun__StrongRef__set(this, globalThis, value);
    }

    pub fn clear(this: *StrongImpl) void {
        jsc.markBinding(@src());
        Bun__StrongRef__clear(this);
    }

    pub fn deinit(
        this: *StrongImpl,
    ) void {
        jsc.markBinding(@src());
        Bun__StrongRef__delete(this);
    }

    extern fn Bun__StrongRef__delete(this: *StrongImpl) void;
    extern fn Bun__StrongRef__new(*jsc.JSGlobalObject, jsc.JSValue) *StrongImpl;
    extern fn Bun__StrongRef__get(this: *StrongImpl) jsc.JSValue;
    extern fn Bun__StrongRef__set(this: *StrongImpl, *jsc.JSGlobalObject, jsc.JSValue) void;
    extern fn Bun__StrongRef__clear(this: *StrongImpl) void;
};

pub const Strong = struct {
    ref: ?*StrongImpl = null,
    globalThis: ?*jsc.JSGlobalObject = null,

    pub fn init() Strong {
        return .{};
    }

    pub fn call(
        this: *Strong,
        args: []const jsc.JSValue,
    ) jsc.JSValue {
        const function = this.trySwap() orelse return .zero;
        return function.call(this.globalThis.?, args);
    }

    pub fn create(
        value: jsc.JSValue,
        globalThis: *jsc.JSGlobalObject,
    ) Strong {
        if (value != .zero) {
            return .{ .ref = StrongImpl.init(globalThis, value), .globalThis = globalThis };
        }

        return .{ .globalThis = globalThis };
    }

    pub fn get(this: *const Strong) ?jsc.JSValue {
        var ref = this.ref orelse return null;
        const result = ref.get();
        if (result == .zero) {
            return null;
        }

        return result;
    }

    pub fn swap(this: *Strong) jsc.JSValue {
        var ref = this.ref orelse return .zero;
        const result = ref.get();
        if (result == .zero) {
            return .zero;
        }

        ref.clear();
        return result;
    }

    pub fn has(this: *const Strong) bool {
        var ref = this.ref orelse return false;
        return ref.get() != .zero;
    }

    pub fn trySwap(this: *Strong) ?jsc.JSValue {
        const result = this.swap();
        if (result == .zero) {
            return null;
        }

        return result;
    }

    pub fn set(this: *Strong, globalThis: *jsc.JSGlobalObject, value: jsc.JSValue) void {
        const ref: *StrongImpl = this.ref orelse {
            if (value == .zero) return;
            this.ref = StrongImpl.init(globalThis, value);
            this.globalThis = globalThis;
            return;
        };
        this.globalThis = globalThis;
        ref.set(globalThis, value);
    }

    pub fn clear(this: *Strong) void {
        const ref: *StrongImpl = this.ref orelse return;
        ref.clear();
    }

    pub fn deinit(this: *Strong) void {
        const ref: *StrongImpl = this.ref orelse return;
        this.ref = null;
        ref.deinit();
    }
};
