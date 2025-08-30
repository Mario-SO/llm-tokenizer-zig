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

<img width="2468" height="1770" alt="CleanShot 2025-08-30 at 20 24 52@2x" src="https://github.com/user-attachments/assets/f8e7b8c9-8fc7-49fc-85c3-3c818495a4db" />

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

## 🚀 Next Steps

* [x] Allow reading text from a file instead of hardcoding
* [ ] Command-line arguments for file input

