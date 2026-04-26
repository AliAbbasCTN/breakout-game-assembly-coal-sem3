.386
.model flat, stdcall
option casemap:none

INCLUDE C:\MASM32\INCLUDE\windows.inc
INCLUDE C:\MASM32\INCLUDE\user32.inc
INCLUDE C:\MASM32\INCLUDE\gdi32.inc
INCLUDE C:\MASM32\INCLUDE\kernel32.inc

INCLUDELIB C:\MASM32\LIB\user32.lib
INCLUDELIB C:\MASM32\LIB\gdi32.lib
INCLUDELIB C:\MASM32\LIB\kernel32.lib

; --- Function Prototypes ---
WinMain PROTO :DWORD, :DWORD, :DWORD, :DWORD

; --- Constants ---
BALL_RADIUS     EQU 10
PADDLE_WIDTH    EQU 80
PADDLE_HEIGHT   EQU 15
BRICK_ROWS      EQU 5
BRICK_COLS      EQU 10
BRICK_WIDTH     EQU 60
BRICK_HEIGHT    EQU 20
BRICK_GAP       EQU 5
WINDOW_WIDTH    EQU 640
WINDOW_HEIGHT   EQU 480
PADDLE_HALF     EQU 40
TOTAL_BRICKS    EQU 50

.DATA
ClassName   db "BreakoutClass",0
AppName     db "MASM32 Breakout",0
LoseMsg     db "GAME OVER! You let the ball drop.", 0
WinMsg      db "CONGRATULATIONS! You cleared all bricks!", 0
RetryCap    db "Breakout Result", 0

ballX       DWORD 320
ballY       DWORD 240
ballDX      DWORD 4
ballDY      DWORD -4
paddleX     DWORD 280
paddleY     DWORD 440  ; Changed from EQU to DWORD to fix A2032
score       DWORD 0
timerID     DWORD 1
bricks      DB TOTAL_BRICKS DUP(1)
gameActive  BYTE 1    

.DATA?
hWndMain    HWND ?
hdc         HDC ?

.CODE

start:
    invoke GetModuleHandle, NULL
    invoke WinMain, eax, NULL, NULL, SW_SHOWDEFAULT
    invoke ExitProcess, 0

WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    push hInst
    pop wc.hInstance
    mov wc.hIcon, NULL
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassName
    mov wc.hIconSm, NULL

    invoke RegisterClassEx, ADDR wc
    invoke CreateWindowEx, 0, ADDR ClassName, ADDR AppName, 
           WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,
           CW_USEDEFAULT, CW_USEDEFAULT, 656, 520, NULL, NULL, hInst, NULL
    mov hWndMain, eax

    invoke ShowWindow, hWndMain, SW_SHOWNORMAL
    invoke UpdateWindow, hWndMain
    invoke SetTimer, hWndMain, timerID, 15, NULL

@@loop:
    invoke GetMessage, ADDR msg, NULL, 0, 0
    cmp eax, 0
    je @@exit
    invoke TranslateMessage, ADDR msg
    invoke DispatchMessage, ADDR msg
    jmp @@loop
@@exit:
    ret
WinMain ENDP

WndProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL i:DWORD, j:DWORD
    LOCAL tempX:DWORD, tempY:DWORD, tempX2:DWORD, tempY2:DWORD

    .IF uMsg == WM_DESTROY
        invoke KillTimer, hWnd, timerID
        invoke PostQuitMessage, 0
    .ELSEIF uMsg == WM_PAINT
        invoke BeginPaint, hWnd, ADDR ps
        mov hdc, eax
        
        ; Draw Paddle
        mov eax, paddleX
        mov ebx, eax
        add ebx, PADDLE_WIDTH
        mov ecx, paddleY
        mov edx, ecx
        add edx, PADDLE_HEIGHT
        invoke Rectangle, hdc, eax, ecx, ebx, edx

        ; Draw Ball
        mov eax, ballX
        mov ebx, ballY
        mov ecx, eax
        mov edx, ebx
        sub eax, BALL_RADIUS
        sub ebx, BALL_RADIUS
        add ecx, BALL_RADIUS
        add edx, BALL_RADIUS
        invoke Ellipse, hdc, eax, ebx, ecx, edx

        ; Draw Bricks
        mov i, 0
        .WHILE i < BRICK_ROWS
            mov j, 0
            .WHILE j < BRICK_COLS
                mov eax, i
                mov ecx, BRICK_COLS
                mul ecx
                add eax, j
                mov esi, OFFSET bricks
                .IF byte ptr [esi+eax] == 1
                    mov eax, j
                    imul eax, (BRICK_WIDTH + BRICK_GAP)
                    add eax, BRICK_GAP
                    mov ebx, i
                    imul ebx, (BRICK_HEIGHT + BRICK_GAP)
                    add ebx, BRICK_GAP
                    
                    mov ecx, eax
                    add ecx, BRICK_WIDTH
                    mov edx, ebx
                    add edx, BRICK_HEIGHT
                    
                    ; Save registers before invoke
                    mov tempX, eax
                    mov tempY, ebx
                    mov tempX2, ecx
                    mov tempY2, edx
                    invoke Rectangle, hdc, tempX, tempY, tempX2, tempY2
                .ENDIF
                inc j
            .ENDW
            inc i
        .ENDW
        invoke EndPaint, hWnd, ADDR ps
    .ELSEIF uMsg == WM_TIMER
        .IF gameActive == 1
            mov eax, ballDX
            add ballX, eax
            mov eax, ballDY
            add ballY, eax

            ; Wall Bouncing
            .IF ballX <= BALL_RADIUS || ballX >= (WINDOW_WIDTH - BALL_RADIUS)
                neg ballDX
            .ENDIF
            .IF ballY <= BALL_RADIUS
                neg ballDY
            .ENDIF

            ; Lose Condition
            .IF ballY >= WINDOW_HEIGHT
                mov gameActive, 0
                invoke KillTimer, hWnd, timerID
                invoke MessageBox, hWnd, ADDR LoseMsg, ADDR RetryCap, MB_OK or MB_ICONEXCLAMATION
                invoke PostQuitMessage, 0
            .ENDIF

            ; Paddle Collision
            mov eax, ballY
            add eax, BALL_RADIUS
            .IF eax >= paddleY
                mov ecx, paddleY
                add ecx, PADDLE_HEIGHT
                .IF eax <= ecx
                    mov ebx, paddleX
                    .IF ballX >= ebx
                        add ebx, PADDLE_WIDTH
                        .IF ballX <= ebx
                            neg ballDY
                            mov eax, paddleY
                            sub eax, BALL_RADIUS
                            mov ballY, eax
                        .ENDIF
                    .ENDIF
                .ENDIF
            .ENDIF

            ; Brick Collision
            mov i, 0
            .WHILE i < BRICK_ROWS
                mov j, 0
                .WHILE j < BRICK_COLS
                    mov eax, i
                    mov ecx, BRICK_COLS
                    mul ecx
                    add eax, j
                    mov esi, OFFSET bricks
                    .IF byte ptr [esi+eax] == 1
                        mov ebx, j
                        imul ebx, (BRICK_WIDTH + BRICK_GAP)
                        add ebx, BRICK_GAP ; Left
                        mov ecx, ebx
                        add ecx, BRICK_WIDTH ; Right
                        mov edx, i
                        imul edx, (BRICK_HEIGHT + BRICK_GAP)
                        add edx, BRICK_GAP ; Top
                        mov edi, edx
                        add edi, BRICK_HEIGHT ; Bottom

                        .IF ballX >= ebx && ballX <= ecx && ballY >= edx && ballY <= edi
                            mov byte ptr [esi+eax], 0
                            neg ballDY
                            inc score
                            .IF score == TOTAL_BRICKS
                                mov gameActive, 0
                                invoke KillTimer, hWnd, timerID
                                invoke MessageBox, hWnd, ADDR WinMsg, ADDR RetryCap, MB_OK or MB_ICONINFORMATION
                                invoke PostQuitMessage, 0
                            .ENDIF
                            jmp @@collision_done
                        .ENDIF
                    .ENDIF
                    inc j
                .ENDW
                inc i
            .ENDW
            @@collision_done:
            invoke InvalidateRect, hWnd, NULL, TRUE
        .ENDIF
    .ELSEIF uMsg == WM_MOUSEMOVE
        mov eax, lParam
        and eax, 0FFFFh
        sub eax, PADDLE_HALF
        .IF sdword ptr eax < 0
            mov eax, 0
        .ELSEIF eax > (WINDOW_WIDTH - PADDLE_WIDTH)
            mov eax, WINDOW_WIDTH - PADDLE_WIDTH
        .ENDIF
        mov paddleX, eax
    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF
    xor eax, eax
    ret
WndProc ENDP

end start