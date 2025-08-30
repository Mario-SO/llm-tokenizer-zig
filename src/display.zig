const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const pricing_module = @import("pricing.zig");

// Using a combination of regular and bold ANSI colors for better visibility
const ColorCode = struct {
    code: []const u8,
};

const COLORS = [_]ColorCode{
    // Regular colors
    .{ .code = "31" }, // Red
    .{ .code = "32" }, // Green
    .{ .code = "33" }, // Yellow
    .{ .code = "34" }, // Blue
    .{ .code = "35" }, // Magenta
    .{ .code = "36" }, // Cyan
    // Bright colors
    .{ .code = "91" }, // Bright Red
    .{ .code = "92" }, // Bright Green
    .{ .code = "93" }, // Bright Yellow
    .{ .code = "94" }, // Bright Blue
    .{ .code = "95" }, // Bright Magenta
    .{ .code = "96" }, // Bright Cyan
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

pub fn printColoredTokens(
    s: []const u8,
    tokens: []const tokenizer.Token,
    allocator: std.mem.Allocator,
) !void {
    var color_map = std.AutoHashMap(Key, ColorCode).init(allocator);
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
        const color = g.value_ptr.*;
        std.debug.print("\x1b[{s}m{s}\x1b[0m", .{ color.code, slice });
    }
    std.debug.print("\n", .{});

    std.debug.print("Total Tokens: {d}\n\n", .{tokens.len});
}

pub fn printPricingTable(token_count: usize) void {
    std.debug.print("╔══════════════════════════════╤═══════════════════╤══════════════════════╗\n", .{});
    std.debug.print("║ Model                        │ Prompt Cost       │ Price per Million    ║\n", .{});
    std.debug.print("╠══════════════════════════════╪═══════════════════╪══════════════════════╣\n", .{});

    for (pricing_module.models) |model| {
        const cost = pricing_module.calculateCost(token_count, model.price_per_million);

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
