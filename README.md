# **x86 Stack Simulator & Calculator**  

**A true stack machine** implemented in x86 Assembly, **simulating CPU stack operations** (`push`/`pop`) using custom `ESP`/`EBP` registers. This project demonstrates low-level stack mechanics while functioning as a RPN calculator.  

---

## 🔥 **Key Features**  
### **1. Real Stack Simulation**  
- **Custom stack pointer (`ESP`)** and **base pointer (`EBP`)** managed in software.  
- **True `PUSH`/`POP` semantics** (mimics hardware behavior).  
- **Stack frames** for modular operations (e.g., function calls).  

### **2. Supported Operations**  
| **Category**       | **Commands**                          | **Example**                     |
|--------------------|---------------------------------------|---------------------------------|
| **Arithmetic**     | `+`, `-`, `*`, `/`, `%` (modulo)     | `N 5 N 3 + =` → `8`             |
| **Stack Control**  | `D` (dup), `R` (swap), `C` (clear)   | `N 4 D = =` → `4 4`             |
| **Inspection**     | `=` (peek), `S` (show), `L` (size)   | `N 10 S` → `10`                 |
| **Data Formats**   | `H` (hex), `B` (binary)              | `N 255 H` → `0xFF`              |
| **System**         | `E` (exit)                           | `E`                             |

### **3. Error Handling**  
- **Stack underflow** (pop from empty stack).  
- **Stack overflow** (exceeds `100` slots).  
- **Division by zero**.  
- **Invalid commands**.  

---

## 🛠 **Technical Deep Dive**  
### **How the Stack Works**  
1. **Registers**:  
   - `[top]` = Software-managed `ESP` (points to top).  
   - `[stack]` = Memory region acting as stack (size: 100 dwords).  
2. **`PUSH` Workflow**:  
   ```asm
   mov ecx, [top]      ; Load ESP
   mov [stack+ecx*4], eax  ; Push value
   inc ecx              ; ESP++
   mov [top], ecx       ; Update ESP
   ```
3. **`POP` Workflow**:  
   ```asm
   dec ecx              ; ESP--
   mov eax, [stack+ecx*4]  ; Pop value
   mov [top], ecx       ; Update ESP
   ```

### **Why This Matters**  
- Teaches **how CPUs manage stacks** at the hardware level.  
- Demonstrates **call stack principles** (used in C/Python/etc.).  
- Useful for **OS development** and **reverse engineering**.  

---

## 📜 **Example Session**  
```plaintext
N 10       ; [10]
N 5        ; [10, 5]
+ =        ; 15
N 3        ; [15, 3]
* =        ; 45
D =        ; 45 45
R S        ; [45, 45] → swapped
E          ; Exit
```

---

## 🚀 **Build & Run**  
### **Linux (NASM + GCC)**  
```sh
nasm -f elf32 calculator.asm -o calc.o
gcc -m32 calc.o -o calc
./calc
```

### **Windows (MinGW)**  
```sh
nasm -f win32 calculator.asm -o calc.obj
gcc -m32 calc.obj -o calc.exe
calc.exe
```

---

## 📌 **Future Roadmap**  
- [ ] **Floating-point support** (x87 FPU).  
- [ ] **Debug mode** (step-through execution).  
- [ ] **JIT compilation** (dynamically translate ops to machine code).  

---

## 📜 **License**  
MIT. Use for **education**, **hacking**, and **low-level experimentation**.   

---

### **Why Build This?**  
- 🧠 **Learn assembly** the hard way.  
- 💡 **Understand stacks** before learning C/Python.  
- 🔥 **Impress recruiters** with bare-metal skills.  

**Try it today!** 🚀
