# 🧩 Byte Pair Encoding (BPE) in Zig

This project is a **minimal implementation of Byte Pair Encoding (BPE)** written in [Zig](https://ziglang.org).  
It takes an input string, repeatedly merges the most frequent adjacent byte pairs, and prints a **colorized tokenization** along with the **total number of tokens**.

---

## ✨ Features

- Pure Zig 0.15 implementation (no dependencies outside `std`)
- Iterative BPE loop:
  - Finds most frequent adjacent byte pairs
  - Merges them into multi-byte tokens
  - Stops when no pair occurs more than once
- ANSI-colored output for easier visualization
- Displays **total token count**

---

## 🔍 Example

Input string:

```
aaabdaaabac
````

Run:

```bash
zig build run
````

Output (with ANSI colors):

<img width="2468" height="1770" alt="CleanShot 2025-08-30 at 19 29 54@2x" src="https://github.com/user-attachments/assets/9f6635da-d993-44f8-b5a2-0b5faa01d17f" />

---

## ⚡ Usage

Build and run:

```bash
zig build run
```

Change the input string inside `main.zig`:

```zig
const words = "aaabdaaabac";
```

---

## 🚀 Next Steps

* [ ] Allow reading text from a file instead of hardcoding

