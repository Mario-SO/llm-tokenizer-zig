const std = @import("std");

pub const Token = struct { 
    start: usize, 
    len: u32 
};

const Key = struct {
    b0: u8,
    b1: u8,
    len: u8,
};

fn keyFromSlice(s: []const u8) Key {
    return .{
        .b0 = s[0],
        .b1 = if (s.len > 1) s[1] else 0,
        .len = @intCast(s.len),
    };
}

pub fn bpeTokenizeAll(s: []const u8, allocator: std.mem.Allocator) ![]Token {
    var toks = std.ArrayList(Token).empty;
    defer toks.deinit(allocator);
    try toks.ensureTotalCapacity(allocator, s.len);
    for (s, 0..) |_, i| {
        toks.appendAssumeCapacity(.{ .start = i, .len = 1 });
    }

    while (true) {
        const target_opt = try mostFrequentAdjacentBytePair(s, toks.items, allocator);
        if (target_opt == null) break;

        const target = target_opt.?;
        var out = std.ArrayList(Token).empty;
        defer out.deinit(allocator);
        try out.ensureTotalCapacity(allocator, toks.items.len);

        var i: usize = 0;
        while (i < toks.items.len) {
            if (i + 1 < toks.items.len) {
                const t0 = toks.items[i];
                const t1 = toks.items[i + 1];
                if (t0.len == 1 and t1.len == 1) {
                    const b0 = s[t0.start];
                    const b1 = s[t1.start];
                    if (b0 == target[0] and b1 == target[1]) {
                        out.appendAssumeCapacity(.{ .start = t0.start, .len = 2 });
                        i += 2;
                        continue;
                    }
                }
            }
            out.appendAssumeCapacity(toks.items[i]);
            i += 1;
        }

        toks.clearRetainingCapacity();
        try toks.appendSlice(allocator, out.items);
    }

    return try toks.toOwnedSlice(allocator);
}

fn mostFrequentAdjacentBytePair(
    s: []const u8,
    tokens: []const Token,
    allocator: std.mem.Allocator,
) !?[2]u8 {
    var map = std.AutoHashMap([2]u8, usize).init(allocator);
    defer map.deinit();

    if (tokens.len < 2) return null;

    var i: usize = 0;
    while (i + 1 < tokens.len) : (i += 1) {
        const t0 = tokens[i];
        const t1 = tokens[i + 1];
        if (t0.len == 1 and t1.len == 1) {
            const pair = [2]u8{ s[t0.start], s[t1.start] };
            const g = try map.getOrPut(pair);
            if (!g.found_existing) g.value_ptr.* = 0;
            g.value_ptr.* += 1;
        }
    }

    var it = map.iterator();
    var best: ?[2]u8 = null;
    var best_cnt: usize = 0;
    while (it.next()) |e| {
        const cnt = e.value_ptr.*;
        if (cnt > best_cnt) {
            best_cnt = cnt;
            best = e.key_ptr.*;
        }
    }

    if (best_cnt <= 1) return null;
    return best;
}