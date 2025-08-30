const std = @import("std");
const words = @embedFile("./prompt.txt");

const Token = struct { start: usize, len: u32 }; // spans into original string

const Key = struct {
    b0: u8,
    b1: u8,
    len: u8, // 1 or 2
};

const Model = struct {
    name: []const u8,
    price_per_million: f64,
};

const models = [_]Model{
    // Cheapest models
    .{ .name = "GPT-5", .price_per_million = 0.0625 },

    // Budget models
    .{ .name = "Gemini 2.5 Pro", .price_per_million = 0.125 },
    .{ .name = "GPT-4o Mini", .price_per_million = 0.15 },

    // Mid-range models
    .{ .name = "o1-mini", .price_per_million = 1.10 },
    .{ .name = "Gemini 1.5 Pro", .price_per_million = 1.25 },

    // Premium models
    .{ .name = "GPT-4o", .price_per_million = 2.50 },
    .{ .name = "Claude 3.5 Sonnet", .price_per_million = 3.00 },
    .{ .name = "Grok 4", .price_per_million = 3.00 },

    // Enterprise models
    .{ .name = "Claude Opus 4", .price_per_million = 15.00 },
    .{ .name = "Claude Opus 4.1", .price_per_million = 15.00 },
    .{ .name = "o1", .price_per_million = 15.00 },

    // Ultra-premium models
    .{ .name = "o3 Pro", .price_per_million = 20.00 },
    .{ .name = "GPT-4.5", .price_per_million = 75.00 },
    .{ .name = "o1 Pro", .price_per_million = 150.00 },
};

fn keyFromSlice(s: []const u8) Key {
    return .{
        .b0 = s[0],
        .b1 = if (s.len > 1) s[1] else 0,
        .len = @intCast(s.len),
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const tokens = try bpeTokenizeAll(words, allocator);
    defer allocator.free(tokens);

    try printColoredTokens(words, tokens, allocator);

    try printPricingTable(tokens.len);
}

fn bpeTokenizeAll(s: []const u8, allocator: std.mem.Allocator) ![]Token {
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

fn printColoredTokens(
    s: []const u8,
    tokens: []const Token,
    allocator: std.mem.Allocator,
) !void {
    const COLORS = [_]u8{ 31, 32, 33, 34, 35, 36, 91, 92, 93, 94, 95, 96 };

    var color_map = std.AutoHashMap(Key, u8).init(allocator);
    defer color_map.deinit();
    var next_color: usize = 0;

    for (tokens) |t| {
        const slice = s[t.start .. t.start + t.len];
        const key = keyFromSlice(slice);
        const g = try color_map.getOrPut(key);
        if (!g.found_existing) {
            g.value_ptr.* = COLORS[next_color % COLORS.len];
            next_color += 1;
        }
        const code = g.value_ptr.*;
        std.debug.print("\x1b[{d}m{s}\x1b[0m", .{ code, slice });
    }
    std.debug.print("\n", .{});

    std.debug.print("Total Tokens: {d}\n\n", .{tokens.len});
}

fn printPricingTable(token_count: usize) !void {
    std.debug.print("╔══════════════════════════════╤═══════════════════╤══════════════════════╗\n", .{});
    std.debug.print("║ Model                        │ Prompt Cost       │ Price per Million    ║\n", .{});
    std.debug.print("╠══════════════════════════════╪═══════════════════╪══════════════════════╣\n", .{});

    for (models) |model| {
        const cost = calculateCost(token_count, model.price_per_million);

        // Format cost with appropriate precision
        if (cost < 0.000001) {
            std.debug.print("║ {s:<28} │ ${d:>16.10} │ ${d:>19.2} ║\n", .{
                model.name,
                cost,
                model.price_per_million,
            });
        } else if (cost < 0.01) {
            std.debug.print("║ {s:<28} │ ${d:>16.8} │ ${d:>19.2} ║\n", .{
                model.name,
                cost,
                model.price_per_million,
            });
        } else {
            std.debug.print("║ {s:<28} │ ${d:>16.6} │ ${d:>19.2} ║\n", .{
                model.name,
                cost,
                model.price_per_million,
            });
        }
    }

    std.debug.print("╚══════════════════════════════╧═══════════════════╧══════════════════════╝\n", .{});
}

fn calculateCost(token_count: usize, price_per_million: f64) f64 {
    return (@as(f64, @floatFromInt(token_count)) / 1_000_000.0) * price_per_million;
}
