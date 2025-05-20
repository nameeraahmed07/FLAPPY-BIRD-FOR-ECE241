# FLAPPY-BIRD-FOR-ECE241
Final Project for ECE241 (Digital Systems)

Flappy Bird is a hardware-based game implemented in Verilog on the Altera DE1-SoC FPGA. Developed over three weeks by two students , the workload was evenly split between game logic, VGA animation, and audio integration.

Display & Input:
-Graphics are rendered on a 160×120-pixel VGA display via a custom VGA controller.
-Player input comes from the on-board pushbuttons (KEY[ ]): pressing a button makes the bird “flap” upward against a constant gravity pull .

Scoring & Indicators:
-Every time the bird successfully passes through a pipe gap, LEDR[0] lights briefly to signal a point.
-The cumulative score is shown in real time on the four 7-segment HEX displays.

Major Subsystems:

Game Logic:
-Calculates the horizontal scrolling of pipes, generates pipe-gap positions, and flags when the bird passes a pipe or collides.

Animation FSM:
-A single finite-state machine handles bird motion (flap, fall), pillar drawing (erase → update → plot), collision detection, and score-pass detection.

Audio Driver:
-Produces simple sound effects for flaps and collisions via the onboard audio codec.

Behavior on Collision & Reset:
Upon detecting a collision (bird hits a pipe), the FSM asserts a reset signal that clears the screen and score, allowing the player to restart immediately.

Top-Level File is vga_demo.v

This design demonstrates the integration of synchronous game state machines with real-time video and audio on an FPGA platform.
