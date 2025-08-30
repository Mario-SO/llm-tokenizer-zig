const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const display = @import("display.zig");

const words = @embedFile("./prompt.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const tokens = try tokenizer.bpeTokenizeAll(words, allocator);
    defer allocator.free(tokens);

    try display.printColoredTokens(words, tokens, allocator);
    display.printPricingTable(tokens.len);
}