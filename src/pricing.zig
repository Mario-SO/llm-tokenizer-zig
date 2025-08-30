const std = @import("std");

pub const Model = struct {
    name: []const u8,
    price_per_million: f64,
};

pub const models = [_]Model{
    .{ .name = "GPT-5", .price_per_million = 0.0625 },
    .{ .name = "Gemini 2.5 Pro", .price_per_million = 0.125 },
    .{ .name = "GPT-4o Mini", .price_per_million = 0.15 },
    .{ .name = "o1-mini", .price_per_million = 1.10 },
    .{ .name = "Gemini 1.5 Pro", .price_per_million = 1.25 },
    .{ .name = "GPT-4o", .price_per_million = 2.50 },
    .{ .name = "Claude 3.5 Sonnet", .price_per_million = 3.00 },
    .{ .name = "Grok 4", .price_per_million = 3.00 },
    .{ .name = "Claude Opus 4", .price_per_million = 15.00 },
    .{ .name = "Claude Opus 4.1", .price_per_million = 15.00 },
    .{ .name = "o1", .price_per_million = 15.00 },
    .{ .name = "o3 Pro", .price_per_million = 20.00 },
    .{ .name = "GPT-4.5", .price_per_million = 75.00 },
    .{ .name = "o1 Pro", .price_per_million = 150.00 },
};

pub fn calculateCost(token_count: usize, price_per_million: f64) f64 {
    return (@as(f64, @floatFromInt(token_count)) / 1_000_000.0) * price_per_million;
}