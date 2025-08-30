# 🧩 LLM Tokenizer with Pricing Calculator in Zig

This project is a **Byte Pair Encoding (BPE) tokenizer** written in [Zig](https://ziglang.org) that tokenizes text and calculates the cost across various LLM providers.

It reads input from `src/prompt.txt`, performs BPE tokenization, and displays a comprehensive pricing table for popular language models.

---

## ✨ Features

- Pure Zig 0.15 implementation (no dependencies outside `std`)
- **BPE Tokenization**:
  - Iteratively finds and merges most frequent adjacent byte pairs
  - Stops when no pair occurs more than once
  - ANSI-colored output for token visualization
- **LLM Pricing Calculator**:
  - Calculates prompt costs
  - Models grouped by price tier (budget to ultra-premium)
  - Displays cost per prompt and price per million tokens
- Reads input from `src/prompt.txt` file

---

## 🔍 Example

Create a file `src/prompt.txt` with your text:

```
Hello world! This is a test prompt.
```

Run:

```bash
zig build run
```

Output:


## ⚡ Usage

1. **Add your text** to `src/prompt.txt`
2. **Build and run**:
 ```bash
 zig build run
 ```

### Adding New Models

To add new LLM models, edit the `models` array in `src/main.zig`:

```zig
const models = [_]Model{
    .{ .name = "Your Model Name", .price_per_million = 0.50 },
    // ... other models
};
```

---

## 📋 Supported Models

The tokenizer includes pricing for:
- **Budget**: Amazon Nova, Gemini Flash, GPT-4o Mini, Claude Haiku
- **Mid-range**: Claude 3.5 Haiku, o1-mini, Gemini Pro
- **Premium**: GPT-4o, Claude 3.5 Sonnet, Grok 3
- **Enterprise**: Claude Opus, o1
- **Ultra-premium**: o3 Pro, GPT-4.5, o1 Pro

---

## 🚀 Next Steps

* [x] Allow reading text from a file instead of hardcoding
* [ ] Command-line arguments for file input

