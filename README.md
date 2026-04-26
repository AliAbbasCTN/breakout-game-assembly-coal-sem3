# 🧱 Atari Breakout Game (Assembly Language)

## 📌 Overview

This project is an implementation of the classic **Atari Breakout game** developed using **Assembly Language**. It was created as part of a **Computer Organization and Assembly Language (COAL)** course in the **3rd semester**.

The game demonstrates low-level programming concepts, direct hardware interaction, and fundamental game logic implementation without the use of high-level libraries.

---

## 🎮 Game Description

Atari Breakout is a classic arcade game where:

* The player controls a paddle
* A ball bounces around the screen
* The objective is to break all bricks without letting the ball fall

---

## 🛠️ Technologies Used

* Assembly Language (x86 / 8086)
* DOS environment / emulator (e.g., DOSBox)
* Low-level screen and keyboard handling

---

## ✨ Features

* Paddle movement using keyboard input
* Ball physics and collision detection
* Brick-breaking mechanics
* Score tracking (if implemented)
* Simple graphical interface using interrupts

---

## ▶️ How to Run

1. Install an emulator like **DOSBox**
2. Assemble the code using an assembler (e.g., MASM / TASM)
3. Run the executable file inside the emulator

Example:

```
tasm breakout.asm
tlink breakout.obj
breakout.exe
```

---

## 📚 Learning Outcomes

This project helped in understanding:

* Low-level programming concepts
* Memory management
* Interrupt handling
* Graphics in Assembly
* Game logic implementation from scratch

---

## 📂 Project Structure

```
/src        -> Assembly source files
/docs       -> Documentation (optional)
/assets     -> Screenshots (optional)
```

---

## 🚀 Future Improvements

* Add sound effects
* Improve graphics
* Add multiple levels
* Optimize collision detection

---

## 👨‍💻 Author

* Your Name
* BS Computer Science (3rd Semester)

---

## 📜 License

This project is for educational purposes.
