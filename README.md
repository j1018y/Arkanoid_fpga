## Introduction

**Arkanoid** is a block-breaking game where the player uses a paddle to keep a ball in play and destroy bricks.  
In this project, we aimed to recreate a basic yet fun version of Arkanoid on FPGA hardware.

---

## Motivation

We share a love for retro video games such as **Donkey Kong**, **Bomberman**, and **Pacman**.  
Originally, we wanted to keep the project simple, but we decided to challenge ourselves by developing an **intermediate-level** game that balances feasibility and complexity.  
Through this project, we deepened our understanding of **Verilog game design** and **VGA output mechanisms**.

---

## Implementation Details

The project mainly consists of several Verilog modules:

- **pong_top**: Top module managing overall state transitions and signal routing.
- **pong_graph**: Handles graphical display of the ball, paddle, and blocks.
- **pong_text**: Manages the text display on screen (e.g., score, game over).
- **m100_counter**: A counter to track the player’s score (up to 99).
- **timer**: A countdown timer used during certain game states.

Additionally, the modules `ascii_rom.v` and `vga_controller.v` were sourced externally and adapted for our use.

Key Features:
- Paddle movement via button inputs.
- Multiple balls (life system).
- Infinite mode and hard mode options.
- Score display with two-digit counter.
- Countdown timer between rounds.

---

## State Diagram

The game follows four major states:

| State        | Description                                                  |
|--------------|---------------------------------------------------------------|
| `newgame`    | Reset the game and wait for the first ball launch.             |
| `play`       | The ball is in play; bounce it to destroy blocks.              |
| `newball`    | Prepare for launching the next ball after a miss.              |
| `over`       | Game over; waits for player to restart.                        |

State transitions are triggered based on button presses, hits, misses, and timer signals.

---

## Modules

### pong_top
- Manages game states, ball launching, and video signal routing.
- Handles transition logic between new game, play, new ball, and game over states.

### pong_graph
- Renders the paddle, ball, and blocks based on pixel coordinates.
- Detects collisions for scoring and ball reflection.

### pong_text
- Displays static text elements (e.g., "PONG", "SCORE", "RULES", "GAME OVER").
- Text is generated using a ROM-based ASCII font.

### m100_counter
- Increments the score when blocks are destroyed.
- Resets or caps score at 99.

### timer
- Provides countdown functionality to create timed delays between states.

---

## Conclusion

Throughout the project, we encountered numerous unexpected challenges — particularly concerning timing, VGA synchronization, and signal control.  
This project not only improved our **Verilog programming skills** but also helped us understand how hardware and graphics integrate at a low level.  
Despite the difficulties, the process was **extremely rewarding** and strengthened our confidence in FPGA development.

---

## Reference

1. Pong Game by fpga4fun - [Link](https://www.fpga4fun.com/PongGame.html)
2. VGA Project Pong Part 2 by David J. Marion - [YouTube](https://www.youtube.com/watch?v=tELTeQb-Dc4)
3. ArkanoidOnVerilog by shaform - [GitHub](https://github.com/shaform/ArkanoidOnVerilog)
4. Pong on VGA Monitor by nandland - [YouTube](https://www.youtube.com/watch?v=sFgNpK4yQwQ)
5. Program Your Own FPGA Video Game by elements14 presents - [YouTube](https://www.youtube.com/watch?v=inrfigeLJeM&t=370s)

---
