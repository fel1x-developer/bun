const std = @import("std");
const bun = @import("root").bun;
const Environment = bun.Environment;
const jsc = bun.jsc;
const string = bun.string;
const Output = bun.Output;
const ZigString = jsc.ZigString;
const Crypto = jsc.API.Bun.Crypto;
const BoringSSL = bun.BoringSSL;
const assert = bun.assert;
const EVP = Crypto.EVP;
const PBKDF2 = EVP.PBKDF2;
const JSValue = jsc.JSValue;
const validators = @import("./util/validators.zig");

fn randomInt(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
    const arguments = callframe.arguments_old(2).slice();

    //min, max
    if (!arguments[0].isNumber()) return globalThis.throwInvalidArgumentTypeValue("min", "safe integer", arguments[0]);
    if (!arguments[1].isNumber()) return globalThis.throwInvalidArgumentTypeValue("max", "safe integer", arguments[1]);
    const min = arguments[0].to(i64);
    const max = arguments[1].to(i64);

    if (min > jsc.MAX_SAFE_INTEGER or min < jsc.MIN_SAFE_INTEGER) {
        return globalThis.throwInvalidArgumentRangeValue("min", "It must be a safe integer type number", min);
    }
    if (max > jsc.MAX_SAFE_INTEGER) {
        return globalThis.throwInvalidArgumentRangeValue("max", "It must be a safe integer type number", max);
    }
    if (min >= max) {
        return globalThis.throwInvalidArgumentRangeValue("max", "should be greater than min", max);
    }
    const diff = max - min;
    if (diff > 281474976710655) {
        return globalThis.throwInvalidArgumentRangeValue("max - min", "It must be <= 281474976710655", diff);
    }

    return jsc.JSValue.jsNumberFromInt64(std.crypto.random.intRangeLessThan(i64, min, max));
}

fn pbkdf2(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
    const arguments = callframe.arguments_old(5);

    const data = try PBKDF2.fromJS(globalThis, arguments.slice(), true);

    const job = PBKDF2.Job.create(jsc.VirtualMachine.get(), globalThis, &data);
    return job.promise.value();
}

fn pbkdf2Sync(globalThis: *jsc.JSGlobalObject, callframe: *jsc.CallFrame) bun.JSError!jsc.JSValue {
    const arguments = callframe.arguments_old(5);

    var data = try PBKDF2.fromJS(globalThis, arguments.slice(), false);
    defer data.deinit();
    var out_arraybuffer = jsc.JSValue.createBufferFromLength(globalThis, @intCast(data.length));
    if (out_arraybuffer == .zero or globalThis.hasException()) {
        data.deinit();
        return .zero;
    }

    const output = out_arraybuffer.asArrayBuffer(globalThis) orelse {
        data.deinit();
        return globalThis.throwOutOfMemory();
    };

    if (!data.run(output.slice())) {
        const err = Crypto.createCryptoError(globalThis, BoringSSL.ERR_get_error());
        BoringSSL.ERR_clear_error();
        return globalThis.throwValue(err);
    }

    return out_arraybuffer;
}

pub fn createNodeCryptoBindingZig(global: *jsc.JSGlobalObject) jsc.JSValue {
    const crypto = jsc.JSValue.createEmptyObject(global, 3);

    crypto.put(global, bun.String.init("pbkdf2"), jsc.JSFunction.create(global, "pbkdf2", pbkdf2, 5, .{}));
    crypto.put(global, bun.String.init("pbkdf2Sync"), jsc.JSFunction.create(global, "pbkdf2Sync", pbkdf2Sync, 5, .{}));
    crypto.put(global, bun.String.init("randomInt"), jsc.JSFunction.create(global, "randomInt", randomInt, 2, .{}));

    return crypto;
}
