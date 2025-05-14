.global _start
.global detect_framebuffer
.global init_pl110
.global fb_print
.global test_framebuffer
.global fb_draw_char
.global detect_resolution
.global fb_hex_print

.section .text

_start:
    bl init_pl110                // Initialize PL110 LCD
    bl detect_framebuffer        // Detect and set framebuffer
    bl detect_resolution         // Auto-detect framebuffer resolution

    ldr r0, =debug_msg
    bl fb_print

hang:
    b hang

// Function: init_pl110
init_pl110:
    ldr r0, =0x10120000           // PL110 Base

    // Set framebuffer address
    ldr r1, =0x00010000           // Framebuffer location (in RAM)
    str r1, [r0, #0x14]           // Set framebuffer base address (QEMU)

    // Set control register (32-bit ARGB, enable)
    ldr r1, =0xC0000827           // 32-bit ARGB, enable
    str r1, [r0, #0x18]

    // Set timing registers (640x480 standard)
    ldr r1, =0x3F1F3F9C
    str r1, [r0, #0x00]
    ldr r1, =0x090B61DF
    str r1, [r0, #0x04]
    ldr r1, =0x067F1800
    str r1, [r0, #0x08]

    // Clear framebuffer (black)
    mov r1, #0x00010000          // Framebuffer start
    mov r2, #0x00000000          // Black color
    mov r3, #0
clear_fb:
    str r2, [r1, r3]
    add r3, r3, #4
    cmp r3, #(640 * 480 * 4)
    blo clear_fb

    bx lr

// Function: detect_framebuffer
// Detects framebuffer base (PL110)
detect_framebuffer:
    ldr r4, =0x00010000           // Direct framebuffer base

fb_found:
    ldr r0, =fb_found_msg
    bl fb_print
    bx lr

// Function: fb_print
fb_print:
    mov r1, #0                    // X position
    mov r2, #0                    // Y position
print_loop:
    ldrb r3, [r0], #1             // Load character
    cmp r3, #0
    beq end_print

    bl fb_draw_char               // Draw character
    add r1, r1, #8
    cmp r1, #640
    blo print_loop

end_print:
    bx lr

// Function: fb_draw_char
fb_draw_char:
    push {r0, r1, r2, r3, r4}

    ldr r4, =0x00010000          // Framebuffer base
    add r4, r4, r2, LSL #10      // Y position
    add r4, r4, r1, LSL #2       // X position

    ldr r0, =0xFFFFFF             // White color
    str r0, [r4]                  // Draw pixel

    pop {r0, r1, r2, r3, r4}
    bx lr

// Function: detect_resolution
// Displays detected resolution (fixed 640x480)
detect_resolution:
    ldr r0, =res_msg
    bl fb_print
    bx lr

// Debug Messages
res_msg:
    .asciz "Resolution: 640x480\n"
fb_found_msg:
    .asciz "Framebuffer Initialized\n"
debug_msg:
    .asciz "Bootloader Running\n"
