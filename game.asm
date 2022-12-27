brick struct
left db 0
right db 3
top db 1
bottom db 0
boundaryline dw 0
health db 1
color db ?
brick ends


.model small
.stack 100h
.data

ballY db 21
ballX db 13
color db 13
paddleLeft db 10
paddleRight db 18
tempT db 0  ;temp storage for time
defaultBrickHealth db 1

bricks brick 8 dup(<,,4,5>)
       brick 8 dup(<,,7,8>)
       brick 8 dup(<,,10,11>)

isMoving db 0
direction_x sbyte  0
direction_y sbyte -1

totalNumberOfBricks db 24
brickCounter db 0
;score

score dw 0
scoreDigit0 db 0
scoreDigit1 db 0
scoreDigit2 db 0
scoreDigit3 db 0
userName db 10 DUP(' ')
levelChoice db 1


menuBackground db 0
startTextColor db ?
resumeTextColor db ?
InstructionTextColor db ?
HighScoreTextColor db ?
exitTextColor db ?

menuChoice db 1

MenuStartBlock DB "New Game$"
MenuResumeBlock DB "Resume Game$"
MenuInstructionBlock DB "Instructions$"
MenuHighScoreBlock DB "High Score$"
MenuExitBlock DB "Exit$"
GameName db "MZ Brick Breaker"

EasyLevelColor db ?
MediumLevelColor db ?
HardLevelColor db ?


EasyLevel DB "Easy Level"
MediumLevel DB "Medium Level"
HardLevel DB "Hard Level"


;Instructions Page data
InstructionWord db "Instructions"
inst1 db "You can move paddle using <- and -> keys"
inst2 db "Break all bricks to win the game."
inst3 db "You have 3 lives,if you miss the ball 3 "
inst4 db "times, You failed !"
inst5 db "There are three levels Easy Medium Hard"
inst6 db "Harder levels give more score."
inst7 db "Press ESC to go back."

instructuonsTextColor db 3

GoodBye db "Good Bye, "

;Main Game screen Header data
noOfLives db 3
heart_x db 6

LivesWord db "Lives: "
ScoreWord db "Score: "


;Resume/Pause screen data
resumeBool db 0
resumeWordColor db 7
pausedWord db "GAME PAUSED"

;sound
soundFreq dw ?
brickCollideSound dw 2000
livesKillSound dw 20000

ballSpeedCX dw 2
ballSpeedDX dw 9240h 

;Game over screen data
gameOverText db "Game Over"
yourScoreWord db "Your Score: "
wantToContinue db "Do you want to continue?"

;file handling
buffert db 500 dup ('$')
handle dw ?
filename db "score.txt",0
; highscore
highScoreWord db "High Score"
tempbuffer db 75 dup(" ")
scoreRow db 9
highScoreText db 16 dup("$")

winScreenWord db "Congrats, You Won!"
;special thing
specialY db 7
specialActive db 0
makeslow db 0
;disappear bricks
disappearCounter db 0
.code
mov ax, @data
mov ds, ax
mov es, ax
mov ax,0
resetPaddle macro
mov paddleLeft,10
.IF levelChoice == 1
    mov paddleRight,18
.ENDIF
.IF levelChoice == 2
    mov paddleRight,16
.ENDIF
.IF levelChoice == 3
    mov paddleRight,14
.ENDIF
mov ballX,13
mov ballY,21
endm

mov ah,0
mov al,13 ;320x200
int 10h
    

mov ah,13h 		; function 13 - write string
mov bp, offset GameName
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,4 		; attribute - magenta
mov cx,16 		; length of string
mov dh,5 		; row to put string
mov dl,12 		; column to put string
int 10h 		; call BIOS service

;Setting cursor at specific location
mov ah,02h  
mov dh, 10     ;row 
mov dl,18     ;column
int 10h

;horizontal 1
mov bx, 80
mov cx, 120 ;row
mov dx, 70;col
mov al, 3
main1:

cmp bx, 0
jne draw1
jmp done1
draw1:
mov ah, 0ch
int 10h

INC cx
DEC bx
jmp main1

done1:


;vertical 1
mov bx, 30
mov cx, 120 ;row
mov dx, 70;col
mov al, 3
main2:

cmp bx, 0
jne draw2
jmp done2
draw2:
mov ah, 0ch
int 10h

INC dx
DEC bx
jmp main2

done2:


;vertical 2
mov bx, 30
mov cx, 200 ;row
mov dx, 70;col
mov al, 3
main3:

cmp bx, 0
jne draw3
jmp done3
draw3:
mov ah, 0ch
int 10h

INC dx
DEC bx
jmp main3

done3:


;horizontal 2
mov bx, 80
mov cx, 120 ;row
mov dx, 100;col
mov al, 3
main4:

cmp bx, 0
jne draw4
jmp done4
draw4:
mov ah, 0ch
int 10h

INC cx
DEC bx
jmp main4

done4:

Mov dx, offset userName
mov cx,10
Mov ah, 3fh
Int 21h
;remove enter key from the string
mov si,0
mov cx,10
removeEnter:
.if userName[si] == 13
mov userName[si],' '
.endif
.if userName[si] == 10
mov userName[si],' '
.endif
inc si
loop removeEnter

Menu:

    .IF resumeBool == 0
        mov resumeWordColor,  7
    .ENDIF

    .IF resumeBool == 1
        mov resumeWordColor,  5
    .ENDIF
        

    call drawBlackScreen
    call menuTextDefaultColor
    
 

    
    cmp menuChoice, 1
    je text1Color
    
    cmp menuChoice, 2
    je resumeBoolCheck

    cmp menuChoice, 3
    je text3Color

    cmp menuChoice, 4
    je text4Color

    cmp menuChoice, 5
    je text5Color

resumeBoolCheck:
.IF resumeBool == 0
inc menuChoice
jmp text3Color
.ENDIF

jmp text2Color


    text1Color:
        mov startTextColor, 10
        jmp skipColorChangeOfMenuText
    text2Color:
        mov resumeWordColor, 10
        jmp skipColorChangeOfMenuText
    text3Color:
        mov InstructionTextColor, 10
        jmp skipColorChangeOfMenuText
    text4Color:
         mov HighScoreTextColor, 10
         jmp skipColorChangeOfMenuText
    text5Color:
        mov exitTextColor, 10



    skipColorChangeOfMenuText:

    mov ah,13h 		; function 13 - write string
    mov bp, offset GameName
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,4		; attribute - red color
    mov cx,16 		; length of string
    mov dh,4 		; row to put string
    mov dl,12 		; column to put string
    int 10h 		; call BIOS service

    mov ah,13h 		; function 13 - write string
    mov bp, offset userName
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,7		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,1		; row to put string
    mov dl,32		; column to put string
    int 10h 

       .IF resumeBool == 1
        call clearAllRegisters
        mov ah, 6
        mov al, 0
        mov bh, 0     ;color
        mov ch, 3   ;top row of window
        mov cl, 12     ;left most column of window
        mov dh, 4    ;Bottom row of window
        mov dl, 28     ;Right most column of window
        int 10h


        mov ah,13h 		; function 13 - write string
        mov bp, offset pausedWord
        mov al,01h 		; attrib in bl,move cursor
        xor bh,bh 		; video page 0
        mov bl,4		; attribute - red color
        mov cx,11 		; length of string
        mov dh,4 		; row to put string
        mov dl,14 		; column to put string
        int 10h 		; call BIOS service

    .ENDIF

;Start TExt
    mov ah,13h 		; function 13 - write string
    mov bp, offset MenuStartBlock
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,startTextColor		; attribute - magenta
    mov cx,8 		; length of string
    mov dh,8 		; row to put string
    mov dl,16 		; column to put string
    int 10h 		; call BIOS service

;resume text
    mov ah,13h 		; function 13 - write string
    mov bp, offset MenuResumeBlock
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,resumeWordColor 		; attribute - magenta
    mov cx,11 		; length of string
    mov dh,11 		; row to put string
    mov dl,15 		; column to put string
    int 10h 		; call BIOS service

    mov ah,13h 		; function 13 - write string
    mov bp, offset MenuInstructionBlock
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,InstructionTextColor 		; attribute - magenta
    mov cx,12 		; length of string
    mov dh,14 		; row to put string
    mov dl,14 		; column to put string
    int 10h 		; call BIOS service


    mov ah,13h 		; function 13 - write string
    mov bp, offset MenuHighScoreBlock
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,HighScoreTextColor 		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,17 		; row to put string
    mov dl,15 		; column to put string
    int 10h 		; call BIOS service


mov ah,13h 		; function 13 - write string
    mov bp, offset MenuExitBlock
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,exitTextColor 		; attribute - magenta
    mov cx,4 		; length of string
    mov dh,20		; row to put string
    mov dl,18 		; column to put string
    int 10h 		; call BIOS service


mov ah, 0
int 16h

cmp al, 13
je checkMenuOption
jmp skipCheckMenuOption

checkMenuOption:
cmp menuChoice, 1
je chooseLevelDifficulty

.IF menuChoice == 2
mov resumeBool, 0
jmp mainGame
.ENDIF

cmp menuChoice, 3
je InstructionPage
cmp menuChoice,4
je highScorePage
cmp menuChoice, 5
je ExitPage


jmp skipMenuChoice

skipMenuChoice:

jmp Menu

skipCheckMenuOption:
.IF resumeBool == 1
    mov resumeWordColor, 5
.ENDIF

cmp ah, 48h
je checkDecreMenu
cmp ah, 50h
je checkIncreMenu

jmp skipAll

checkIncreMenu:
cmp menuChoice, 5
jl IncrementMenu
jmp skipAll

checkDecreMenu:
.IF resumeBool == 0 && menuChoice == 3
    dec menuChoice
.ENDIF

cmp menuChoice, 1
jg DecrementMenu

jmp skipAll


IncrementMenu:
inc menuChoice
jmp skipAll

DecrementMenu:
dec menuChoice

skipAll:



jmp Menu


menuTextDefaultColor proc uses ax bx cx dx

mov startTextColor, 5
;if 
mov resumeTextColor, 5
mov InstructionTextColor, 5
mov HighScoreTextColor, 5
mov exitTextColor, 5

ret
menuTextDefaultColor endp




; ++++++++++++++++++ LEVEL DIFFICULTY PAGE +++++++++++++++++++++++++++++
chooseLevelDifficulty:
call drawBlackScreen
Levels:

    call levelTextDefaultColor
    cmp levelChoice, 1
    je levelText1Color
    
    cmp levelChoice, 2
    je levelText2Color

    cmp levelChoice, 3
    je levelText3Color

    levelText1Color:
    
        mov EasyLevelColor, 10
        jmp skipColorChangeOfLevelText
    levelText2Color:
        mov MediumLevelColor, 10
        jmp skipColorChangeOfLevelText
    levelText3Color:
        mov HardLevelColor, 10
        jmp skipColorChangeOfLevelText


    skipColorChangeOfLevelText:

;Start TExt

    mov ah,13h 		; function 13 - write string
    mov bp, offset GameName
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,6		; attribute - magenta
    mov cx,16 		; length of string
    mov dh,4 		; row to put string
    mov dl,12 		; column to put string
    int 10h 		; call BIOS service

    mov ah,13h 		; function 13 - write string
    mov bp, offset EasyLevel
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,EasyLevelColor		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,10 		; row to put string
    mov dl,16 		; column to put string
    int 10h 		; call BIOS service

;resume text
    mov ah,13h 		; function 13 - write string
    mov bp, offset MediumLevel
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,MediumLevelColor 		; attribute - magenta
    mov cx,12 		; length of string
    mov dh,13 		; row to put string
    mov dl,15 		; column to put string
    int 10h 		; call BIOS service

    mov ah,13h 		; function 13 - write string
    mov bp, offset HardLevel
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,HardLevelColor 		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,16 		; row to put string
    mov dl,16 		; column to put string
    int 10h 		; call BIOS service


mov ah, 0
int 16h

cmp al, 13
je checkLevelOption
.IF al == 27
    jmp Menu
.ENDIF
jmp skipCheckLevelOption

checkLevelOption:
mov score,0
mov noOfLives,3
cmp levelChoice, 1
je startLevel1
cmp levelChoice, 2
je startLevel2
cmp levelChoice, 3
je startLevel3

skipCheckLevelOption:

cmp ah, 48h
je checkDecreLevel
cmp ah, 50h
je checkIncreLevel

jmp skipAll1

checkIncreLevel:
cmp levelChoice, 3
jl IncrementLevel
jmp skipAll1

checkDecreLevel:
cmp levelChoice, 1
jg DecrementLevel
jmp skipAll1


IncrementLevel:
inc levelChoice
jmp skipAll1

DecrementLevel:
dec levelChoice

skipAll1:

jmp Levels

levelTextDefaultColor proc uses ax bx cx dx
mov EasyLevelColor, 5
mov MediumLevelColor, 5
mov HardLevelColor, 5

ret
levelTextDefaultColor endp

; ++++++++++++++++++ Instruction Page +++++++++++++++++++++++++++++
InstructionPage:

call drawBlackScreen

    mov ah,13h 		; function 13 - write string
    mov bp, offset InstructionWord
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,4		; attribute - magenta
    mov cx, 12		; length of string
    mov dh,2		; row to put string
    mov dl,13		; column to put string
    int 10h 

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst1
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx, 40 		; length of string
    mov dh,5		; row to put string
    mov dl,0		; column to put string
    int 10h 

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst2
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,33 		; length of string
    mov dh,8		; row to put string
    mov dl,3		; column to put string
    int 10h

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst3
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,40 		; length of string
    mov dh,11		; row to put string
    mov dl,0		; column to put string
    int 10h

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst4
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,19 		; length of string
    mov dh,14		; row to put string
    mov dl,9		; column to put string
    int 10h

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst5
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,39 		; length of string
    mov dh,17		; row to put string
    mov dl,0		; column to put string
    int 10h

    mov ah,13h 		; function 13 - write string
    mov bp, offset inst6
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,30 		; length of string
    mov dh,20		; row to put string
    mov dl,5		; column to put string
    int 10h
    
    mov ah,13h 		; function 13 - write string
    mov bp, offset inst7
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,instructuonsTextColor		; attribute - magenta
    mov cx,21 		; length of string
    mov dh,23		; row to put string
    mov dl,9		; column to put string
    int 10h


    mov ah, 0
    int 16h

    cmp al, 27
    je Menu

    jmp InstructionPage

; ++++++++++++++++++ HighScore Page +++++++++++++++++++++++++++++
highScorePage:

call drawBlackScreen
    ;file handling

    mov ah,13h 		; function 13 - write string
    mov bp, offset highScoreWord
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,4		; attribute - magenta
    mov cx, 10		; length of string
    mov dh,2		; row to put string
    mov dl,13		; column to put string
    int 10h 
    
    mov ah, 3DH
    mov al, 2
    mov dx, offset filename
    int 21h
    mov handle,ax
    mov al, 0
    mov bx, handle 
    mov cx, 0 
    mov dx, 0
    mov ah, 42h 
    int 21h ; seek...

    ;file read
    mov bx, handle 
    mov dx, offset buffert
    mov cx, 1000
    mov ah, 3fh 
    int 21h

.IF buffert[0] == '$'
    jmp escapeinput
.ENDIF

    ;file exit
    mov ah, 3Eh
    mov bx, handle
    int 21h
    mov si,0
    ;calculate total number of enteries in file
    .while buffert[si]!='$'
    inc si
    .endw

    mov cx,0
    mov ax,0
    mov ax,si
    mov bl,15
    div bl
    mov cl,al

    mov si,0

    push cx
    ; remove previous enteries
    .if cl >5

    mov ah, 3DH
    mov al, 2
    mov dx, offset filename
    int 21h
    mov handle,ax   

    ;move cursor position
    mov cx,0
    mov dx, 15
    mov bx, handle
    mov ah,42h
    mov al,0
    int 21h
    ;file read
    mov bx, handle 
    mov dx, offset tempbuffer
    mov cx, 75
    mov ah, 3fh 
    int 21h
    ;move cursor to the start
    mov cx,0
    mov dx, 0
    mov bx, handle
    mov ah,42h
    mov al,0
    int 21h

    mov ah, 40H
    mov bx, handle
    mov cx, 0
    int 21h
    ;write extra data
    mov ah, 40H
    mov bx, handle
    mov cx, 75
    mov dx, offset tempbuffer
    int 21h


    mov al, 0
    mov bx, handle 
    mov cx, 0 
    mov dx, 0
    mov ah, 42h 
    int 21h ; seek...

    ;file read
    mov bx, handle 
    mov dx, offset buffert
    mov cx, 1000
    mov ah, 3fh 
    int 21h

    ;file exit
    mov ah, 3Eh
    mov bx, handle
    int 21h

    .endif
    pop cx
    .if cx > 5
    mov cx,5
    .endif
    mov scoreRow,5

    readScore:
    mov di,0
    push cx
    mov cx,0
    ;score
    getScore:
    mov dl,buffert[si]
    mov highScoreText[di],dl

    inc cx
    inc si
    inc di
    cmp cx,4
    jl getScore


    ;name
    mov cx,0
    getname:
    ; temp name
    mov dl,buffert[si]
    mov highScoreText[di],dl
    inc cx
    inc di
    inc si
    cmp cx,10
    jl getname


    ;templevel
    mov dl,buffert[si]
    mov highScoreText[di],dl

    mov ah,13h 		; function 13 - write string
    mov bp, offset highScoreText
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,10 		; attribute - magenta
    mov cx,4 		; length of string
    mov dh,scoreRow		; row to put string
    mov dl, 17 		; column to put string
    int 10h 

    mov ah,13h 		; function 13 - write string
    mov bp, offset [highScoreText+4]
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,10 		; attribute - magenta
    mov cx,10		; length of string
    mov dh,scoreRow		; row to put string
    mov dl, 5	; column to put string
    int 10h 

    mov ah,13h 		; function 13 - write string
    mov bp, offset [highScoreText+14]
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,10 		; attribute - magenta
    mov cx,1		; length of string
    mov dh,scoreRow		; row to put string
    mov dl, 24	; column to put string
    int 10h 
    add scoreRow,2
    inc si
    pop cx
    loop readScore
   
    ;file handling
    escapeinput:    
    mov ah, 0
    int 16h

    cmp al, 27
    je Menu
    jmp escapeinput

;++++++++++++++++++++++++++++++++++ Exit Screen ++++++++++++++++++++++++++=

ExitPage:
call drawBlackScreen

    mov ah,13h 		; function 13 - write string
    mov bp, offset GoodBye
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,3		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,10		; row to put string
    mov dl,11		; column to put string
    int 10h 

    mov ah,13h 		; function 13 - write string
    mov bp, offset userName
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,3		; attribute - magenta
    mov cx,10 		; length of string
    mov dh,10		; row to put string
    mov dl,21		; column to put string
    int 10h

    jmp exit

;++++++++++++++++++++++++++++++++++ Pause Screen ++++++++++++++++++++++++++
pauseScreen:
mov resumeBool, 1
mov menuChoice, 2
jmp Menu


;++++++++++++++++++++++++++++++++++ GAME OVER Screen ++++++++++++++++++++++++++=
GameOverScreen:
; store the name and score
call storeScore
mov ah,13h 		; function 13 - write string
mov bp, offset gameOverText
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,4 		; attribute - magenta
mov cx,9 		; length of string
mov dh,5 		; row to put string
mov dl,15 		; column to put string
int 10h 		; call BIOS service

call endScreenScoreShow


mov ah,13h 		; function 13 - write string
mov bp, offset wantToContinue
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,6 		; attribute - magenta
mov cx,24 		; length of string
mov dh,13		; row to put string
mov dl,7 		; column to put string
int 10h 		; call BIOS service

;cursor
mov ah,02h  
mov dh, 16     ;row 
mov dl, 15     ;column
int 10h

mov dl, 'Y'
mov ah, 2
int 21h

;cursor
mov ah,02h  
mov dh, 16     ;row 
mov dl, 22    ;column
int 10h

mov dl, 'N'
mov ah, 2
int 21h

wantToContinueChoice:
mov ah, 0
int 16h

.if al == 'Y' || al == 'y'
jmp Menu
.endif

.if al == 'N' || al == 'n'
jmp ExitPage
.endif

jmp wantToContinueChoice

;++++++++++++++++++++++++++++++++++ Win Screen ++++++++++++++++++++++++++=
WinScreen:
call storeScore
mov ah,13h 		; function 13 - write string
mov bp, offset winScreenWord
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,4 		; attribute - magenta
mov cx,18 		; length of string
mov dh,5 		; row to put string
mov dl,11 		; column to put string
int 10h 		; call BIOS service


call endScreenScoreShow


mov ah,13h 		; function 13 - write string
mov bp, offset wantToContinue
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,6 		; attribute - magenta
mov cx,24 		; length of string
mov dh,13		; row to put string
mov dl,7 		; column to put string
int 10h 		; call BIOS service

;cursor
mov ah,02h  
mov dh, 16     ;row 
mov dl, 15     ;column
int 10h

mov dl, 'Y'
mov ah, 2
int 21h

;cursor
mov ah,02h  
mov dh, 16     ;row 
mov dl, 22    ;column
int 10h

mov dl, 'N'
mov ah, 2
int 21h

wantToContinueChoiceWin:
mov ah, 0
int 16h

.if al == 'Y' || al == 'y'
jmp Menu
.endif

.if al == 'N' || al == 'n'
jmp ExitPage
.endif

jmp wantToContinueChoiceWin


;++++++++++++++++++++++++++++++++++ MAIN GAME STARTS FROM HERE ++++++++++++++++++++++++++=
mainGame:

mov ax,0
mov cx,0
mov bx,0
mov dx,0
;time interupt
mov ah,2ch

int 21h

call drawBlackScreen

call clearAllRegisters
    cmp noOfLives,0
    je GameOverScreen ; go to Game over screen
    mov ah,13h 		; function 13 - write string
    mov bp, offset LivesWord
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,15		; attribute - magenta
    mov cx,7 		; length of string
    mov dh,2 		; row to put string
    mov dl,0 		; column to put string
    int 10h

    mov ah,13h 		; function 13 - write string
    mov bp, offset userName
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,15		; attribute - magenta
    mov cx,4 		; length of string
    mov dh,1 		; row to put string
    mov dl,32 		; column to put string
    int 10h
    
    mov ah,13h 		; function 13 - write string
    mov bp, offset ScoreWord 
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,15		; attribute - magenta
    mov cx,7 		; length of string
    mov dh,03		; row to put string
    mov dl,30 		; column to put string
    int 10h

    mov ah,02h  
	mov dh, 3     ;row 
	mov dl,37     ;column
	int 10h
    call showScore

    cmp levelChoice, 1
    je printEasyLevel
    cmp levelChoice, 2
    je printMediumLevel
    cmp levelChoice, 3
    je printHardLevel

    printEasyLevel:
    mov si, offset EasyLevel
    mov cx, 10
    jmp printlevelChoice

    printMediumLevel:
    mov si, offset MediumLevel
    mov cx, 12
    jmp printlevelChoice

    printHardLevel:
    mov si, offset HardLevel
    mov cx, 10
    jmp printlevelChoice

    printlevelChoice:
    mov ah,13h 		; function 13 - write string
    mov bp, si
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,15		; attribute - magenta
    ;mov cx,7 		; length of string
    mov dh,02		; row to put string
    mov dl,14 		; column to put string
    int 10h
    call drawLiveHearts

call drawSpecial
call bricksDraw
call drawBall
call drawPaddle

.if specialActive==1 && specialY<25
inc specialY
.endif

mov ax, 0

mov al, totalNumberOfBricks
cmp al, brickCounter
je nextLevel

mov ax, 0

mov ah, 1
int 16h
jz ballcheck
mov ah, 0
int 16h
cmp ah, 4bh
je leftKey
cmp ah, 4dh
je rightKey
cmp al, 27
je pauseScreen

ballcheck:
;ball moving
cmp al, 32
je isMovingTrue
jmp isMovingSkip

isMovingTrue:
mov isMoving, 1
isMovingSkip:

; print
cmp isMoving, 1
jne isNotMoving


MOV     CX, ballSpeedCX
MOV     DX, ballSpeedDX;9240H
MOV     AH, 86H
INT     15H

cmp ballY, 22
je checkPaddleCollision
cmp ballY, 23
jge collide
cmp ballX, 0
jle collide
cmp ballX, 39
jge collide
cmp ballY, 4
jle collide


jmp skip1

collide:

call checkdirection
skip1:
call brickCollision

mov bl,direction_x
add ballX,bl

mov bl,direction_y
add ballY,bl


.if makeslow==1 && levelChoice==3
mov ballSpeedCX,2
mov ballSpeedDX,3000h
.endif
jmp mainGame


drawBlackScreen proc
push ax
push bx
push cx
push dx
mov ah, 6
mov al, 0
mov bh, 0    ;color
mov ch, 0   ;top row of window
mov cl, 0    ;left most column of window
mov dh, 24    ;Bottom row of window
mov dl, 40    ;Right most column of window
int 10h
pop ax
pop bx
pop cx
pop dx
ret
drawBlackScreen endp


checkdirection proc uses ax bx cx dx
    
    mov bl, 1
    cmp direction_y,bl
    je down
    jne up
    up:
    ; y =1

    cmp direction_x,bl
    je upRight
    jne upLeft

    upRight:
    ;x=1
    cmp direction_x,0
    je centre

    mov bl,39
    cmp ballX,bl
    jge rightmost
    

    mov direction_y,1
    mov direction_x,1
    jmp checkend
    rightmost:
    mov direction_y,-1
    mov direction_x,-1
    jmp checkend

    upLeft:
    ;x=-1
    cmp direction_x,0
    je centre

    
    cmp ballY,4
    jle upmost
    
    mov direction_y, -1
    mov direction_x, 1
    jmp checkend

    upmost:
    mov direction_y,1
    mov direction_x,-1
    jmp checkend

    centre:
    inc ballY
    mov direction_y, 1
    mov direction_x, 0
    jmp checkend


;;;down
    down:
    ; y =-1
    cmp direction_x,bl
    je downRight
    jne downLeft
    downRight:
    mov bl,38
    cmp ballX,bl
    jge rightmost1
    ;x=1
    mov direction_y,-1
    mov direction_x,1
    jmp checkend
    rightmost1:
    mov direction_y,1
    mov direction_x,-1
    jmp checkend
    
    
    downLeft:
    ;x=-1

    mov bh,23
    cmp ballY,bh
    jge downmost
    mov direction_y,1
    mov direction_x,1
    jmp checkend
    downmost:
    mov direction_y,-1
    mov direction_x,-1
    jmp checkend

    checkend:
    cmp ballX,39
    jl checkSkip
    dec ballX
    cmp ballX,0
    jg checkSkip
    inc ballX
    cmp ballY,4
    jg checkSkip
    cmp ballX,0
    jle checkSkip
    dec ballY
    dec ballX
    dec ballY
    dec ballX
    checkSkip:
    ret
checkdirection endp

;checks paddle collision with ball
checkPaddleCollision: 

mov dl,ballX
cmp paddleLeft,dl
jle next1
;TODO life minus
mov ax, 0
mov ax, livesKillSound
mov soundFreq,ax
mov cx,1
call playSound

dec noOfLives
mov isMoving,0
mov BallX,13
mov BallY,21
resetPaddle
mov direction_x,0
mov direction_y,-1
jmp mainGame
next1:
cmp paddleRight,dl
jae next2
;change to default
;TODO life minus
mov ax, 0
mov ax, livesKillSound
mov soundFreq,ax
mov cx,1

call playSound
dec noOfLives
mov isMoving,0
mov BallX,13
mov BallY,21

resetPaddle
mov direction_x,0
mov direction_y,-1
jmp mainGame
next2:


mov al,paddleLeft
add al,paddleRight
mov bh,2
div bh


cmp al,ballX
jl padLeft
jg padRight
je padCenter
padLeft:
mov color,10
mov direction_x,1
mov direction_y,-1
jmp skip1
padRight:
mov color,11
mov direction_x, -1
mov direction_y,-1
jmp skip1
padCenter:
mov color,9
mov direction_x, 0
mov direction_y,-1
jmp skip1

drawBall proc uses ax bx cx dx
    mov ah, 6
    mov al, 0
    mov bh, color    ;color
    mov ch, ballY     ;top row of window
    mov cl, ballX     ;left most column of window
    mov dh, ballY    ;Bottom row of window
    mov dl, ballX       ;Right most column of window
    int 10h
    ret
drawBall endp

;description
drawPaddle PROC
mov ah, 6
mov al, 0
mov bh, 3     ;color
mov ch, 23   ;top row of window
mov cl, paddleLeft     ;left most column of window
mov dh, 23    ;Bottom row of window
mov dl, paddleRight     ;Right most column of window
int 10h
ret
drawPaddle ENDP

;assigns the default value to the brick
assignVals proc uses ax bx cx dx
; make this a macro later
mov si,0
mov dh,0
mov cx,24; number of
mov bx,0;boundary line
mov dl,0

assignVal:
;rows
push bx
mov bl,defaultBrickHealth
mov bricks[si].health,bl
pop bx
cmp dl,16
je changeheight

cmp dl,8
je changeheight

jmp maintainHeight

changeheight:
mov dh,0
maintainHeight:

mov (bricks[si]).left,dh
add dh,4
mov (bricks[si]).right,dh
sub dh,4
add dh,5
mov (bricks[si]).boundaryline,bx
add bx,40
add si,sizeof brick
inc dl
loop assignVal

ret
assignVals endp

; draws the bricks
bricksDraw proc uses ax bx cx dx
mov si,0
mov cx,24
drawbricks:
push cx

cmp bricks[si].health,0
jle skipDraw

.if bricks[si].health ==3
mov bh,9h
.endif
.if bricks[si].health ==2
mov bh,2h
.endif
.if bricks[si].health ==1
mov bh,4h
.endif
;if special brick
.if si == 96 && levelChoice==3
mov bh,5h
.endif
.if si == 120 && levelChoice==3
mov bh,0111b
.endif
.if si == 16 && levelChoice==3
mov bh,1000b
.endif
mov ah, 6
mov al, 0
mov ch,  bricks[si].top   ;top row of window
mov cl, bricks[si].left    ;left most column of window
mov dh, bricks[si].bottom ;Bottom row of window
mov dl, bricks[si].right   ;Right most column of window
int 10h

skipDraw:
;draw gap
mov ah, 6
mov al, 0
mov bh,0 ;black color 
mov ch,  bricks[si].top   ;top row of window
mov cl, bricks[si].right    ;left most column of window
mov dh, bricks[si].bottom ;Bottom row of window
mov dl, bricks[si].right   ;Right most column of window
int 10h


pop cx
add si,sizeof brick
; loop capacity reached so looping manually with jump
dec cx
jnz drawbricks
ret
bricksDraw endp


leftKey:
sub paddleLeft, 1
sub paddleRight, 1
mov bh,0
cmp isMoving,bh
je moveBallLeft 

jmp checkPaddleLeftMove

rightKey:
add paddleLeft, 1
add paddleRight, 1
mov bh,0
cmp isMoving,bh
je moveBallRight 
jmp checkPaddleRightMove

checkPaddleLeftMove:
cmp paddleLeft, -1
jle retainLeftPaddle
jmp mainGame

checkPaddleRightMove:
cmp paddleRight, 40
jae retainRightPaddle
jmp mainGame


retainLeftPaddle:
add paddleLeft, 1
add paddleRight, 1
mov bh,0
cmp isMoving,bh
je retainBallLeft

jmp mainGame

retainRightPaddle:
sub paddleLeft, 1
sub paddleRight, 1
mov bh,0
cmp isMoving,bh
je retainBallRight

jmp mainGame

isNotMoving:
MOV     CX, 0h
MOV     DX, 9240H
MOV     AH, 86H
INT     15H
jmp mainGame

moveBallLeft:
sub ballX, 1
jmp checkPaddleLeftMove

moveBallRight:
add ballX,1
jmp checkPaddleRightMove

retainBallRight:
sub ballX,1
jmp mainGame
retainBallLeft:
add ballX,1
jmp mainGame

; logic for collision with breaks
brickCollision proc uses ax bx cx dx
mov bh,ballX
mov bl,ballY
mov al, ballY
dec bl
inc al
mov si,0
mov cx,24

checkBricks:

cmp bricks[si].health,0
jle noCollsion
cmp bl,bricks[si].bottom
jg noCollsion
cmp al,bricks[si].top
jl noCollsion
cmp bh,bricks[si].left
jl noCollsion
cmp bh,bricks[si].right
jg noCollsion

;will reach this point in case of collision
.IF ballX == 0 
inc ballX
inc ballY
.ENDIF

mov ax, 0
mov ax, brickCollideSound
mov soundFreq,ax
mov cx,1
call playSound

mov di, sizeof brick
mov ax, 0
mov ax, 8
add di, ax
;fixed bric
.IF si == di && levelChoice == 3
    jmp skipBrickDecHealth
.ENDIF
;special brick that shoots powerup
.if  si==96 && levelChoice== 3 && bricks[si].health!=0
mov specialActive,1
mov bricks[si].health,0
add brickCounter,3
add score,30
jmp skipBrickDecHealth
.endif
;special brick that disappears
.if  si==120 && levelChoice== 3  && bricks[si].health!=0
mov al, bricks[si].health
add brickCounter, al
mov bricks[si].health,0
add score,30
call disappearBricks

jmp skipBrickDecHealth
.endif

add score,10


dec bricks[si].health
inc brickCounter

skipBrickDecHealth:

mov dh,direction_x
mov dl,direction_y
; checking the directions of the ball
;up direction
cmp dl,-1
je updirection
jne downdirection ; if y=1

updirection:
;check left

cmp dh,-1
je checkUpLeft
cmp direction_x,0
jne checkUpRight
;
mov direction_x,0
mov direction_y,1
jmp noCollsion
;for upright
checkUpRight: ;x=1 , y=-1

mov direction_x,1
mov direction_y,1

jmp noCollsion

checkUpLeft:
mov direction_x,-1
mov direction_y,1

jmp noCollsion

downdirection: ;y=1
cmp dh,-1
je checkDownLeft
checkDownRight:
mov direction_x, 1
mov direction_y,-1


jmp noCollsion
checkDownLeft:
mov direction_x,-1
mov direction_y,-1

jmp noCollsion

;all above this will execute when ball collides with a brick
noCollsion:
add si,sizeof brick
dec cx
jnz checkBricks; loop byte limit exceeded so using this
ret 
brickCollision endp

drawLiveHearts proc uses ax bx cx dx
mov cx, 0
mov cl, noOfLives
mov heart_x,6
outer:
    
    mov ah,02h  
	mov dh, 2     ;row 
	mov dl,heart_x     ;column
	int 10h

    mov ah, 02h ; num print
    mov dl, 3
    int 21h
    inc heart_x
loop outer
ret 
drawLiveHearts endp

clearAllRegisters proc
mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0
ret
clearAllRegisters endp

playSound proc
push cx

    mov cx,1
	mov al, 182
	out 43h, al
	mov ax, soundFreq
	
	out 42h, al
	mov al, ah
	out 42h, al
	in al, 61h
    
	or al, 3
	out 61h, al
	mov dx, 4240h
	mov ah, 86h
	int 15h
	in al, 61h
	
	and al, 11111100b
	out 61h, al

pop cx
ret
playSound endp

endScreenScoreShow proc

    mov ah,13h 		; function 13 - write string
    mov bp, offset yourScoreWord
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,7 		; attribute - magenta
    mov cx,12 		; length of string
    mov dh,9 		; row to put string
    mov dl,11 		; column to put string
    int 10h 		; call BIOS service


    mov si,0
    mov cx,4
    convertScoreChar:
    add scoreDigit0[si],'0'
    inc si
    loop convertScoreChar
    mov ah,13h 		; function 13 - write string
    mov bp, offset scoreDigit0
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,7 		; attribute - magenta
    mov cx,4 		; length of string
    mov dh,9 		; row to put string
    mov dl, 23 		; column to put string
    int 10h 
            ; call BIOS service
    mov cx,4
    mov si,0

    convertScoreInt:
    sub scoreDigit0[si],'0'
    inc si
    loop convertScoreInt
ret
endScreenScoreShow endp

;show the score
showScore proc uses ax bx cx dx

.IF score < 100
mov ax, 0
mov al, byte ptr [score]
mov bl, 0
mov bl, 10
div bl
mov scoreDigit2, al
mov scoreDigit3, ah

;changing cursor
mov ah,02h  
mov dh, 3     ;row 
mov dl, 38     ;column
int 10h

mov dl, scoreDigit2
add dl, '0'
mov ah, 2
int 21h

;changing cursor
mov ah,02h  
mov dh, 3     ;row 
mov dl, 39     ;column
int 10h

mov dl, scoreDigit3
add dl, '0'
mov ah, 2
int 21h

.ENDIF


.IF score >= 100

mov ax, 0
mov dx, score
mov ax, dx
mov bl, 0
mov bl, 10
div bl
mov scoreDigit3, ah
mov dx,  0
mov dl, al
mov ah, 0
mov al, dl
div bl
mov scoreDigit2, ah
mov scoreDigit1, al

mov ah,02h  
mov dh, 3     ;row 
mov dl, 37    ;column
int 10h
mov dl, scoreDigit1
add dl, '0'
mov ah, 2
int 21h

mov ah,02h  
mov dh, 3     ;row 
mov dl, 38     ;column
int 10h

mov dl, scoreDigit2
add dl, '0'
mov ah, 2
int 21h

mov ah,02h  
mov dh, 3     ;row 
mov dl, 39     ;column
int 10h

mov dl, scoreDigit3
add dl, '0'
mov ah, 2
int 21h

.ENDIF


.IF score >= 1000

mov ax, 0
mov dx, score
mov ax, dx
mov bl, 0
mov bl, 10
div bl
mov scoreDigit3, ah
mov dx,  0
mov dl, al
mov ah, 0
mov al, dl
div bl
mov scoreDigit2, ah
mov dl, al
mov ah, 0
mov al, dl
div bl
mov scoreDigit1, ah
mov scoreDigit0, al


mov ah,02h  
mov dh, 3     ;row 
mov dl, 36    ;column
int 10h
mov dl, scoreDigit0
add dl, '0'
mov ah, 2
int 21h

mov ah,02h  
mov dh, 3     ;row 
mov dl, 37    ;column
int 10h
mov dl, scoreDigit1
add dl, '0'
mov ah, 2
int 21h

mov ah,02h  
mov dh, 3     ;row 
mov dl, 38     ;column
int 10h

mov dl, scoreDigit2
add dl, '0'
mov ah, 2
int 21h

mov ah,02h  
mov dh, 3     ;row 
mov dl, 39     ;column
int 10h

mov dl, scoreDigit3
add dl, '0'
mov ah, 2
int 21h

.ENDIF

ret
showScore endp

; start levels
startLevel3:
mov direction_x, 0
mov direction_y, -1
mov isMoving,0
resetPaddle
mov defaultBrickHealth,3
mov levelChoice,3
mov totalNumberOfBricks, 69
mov brickCounter,0
mov ballSpeedCX, 1
mov ballSpeedDX, 5000h
mov paddleRight, 14 
mov specialY,7
mov specialActive,0
mov makeslow,0
call assignVals
jmp mainGame

startLevel2:
mov isMoving,0
mov direction_x, 0
mov direction_y, -1
resetPaddle
mov defaultBrickHealth,2
mov brickCounter,0
mov totalNumberOfBricks, 48
mov levelChoice, 2
mov ballSpeedCX, 2
mov ballSpeedDX, 3000h 
mov paddleRight, 16
call assignVals
jmp mainGame


startLevel1:
mov direction_x, 0
mov direction_y, -1
mov isMoving,0
resetPaddle
mov defaultBrickHealth,1
mov totalNumberOfBricks, 24
mov levelChoice ,1
mov brickCounter,0
mov ballSpeedCX, 2
mov ballSpeedDX, 9240h 
mov paddleRight, 18
call assignVals
jmp mainGame


nextLevel:
.if levelChoice == 1
jmp startLevel2
.endif
.if levelChoice == 2
jmp startLevel3
.endif
.if levelChoice == 3
call drawBlackScreen
jmp WinScreen
.endif

storeScore proc
;store score

mov ah, 3DH
mov al, 2
mov dx, offset filename
int 21h
mov handle,ax   

mov al, 2
mov bx, handle 
mov cx, 0 
mov dx, 0
mov ah, 42h 
int 21h ; seek...

mov si,0
mov cx,4
convertScoreChar1:
add scoreDigit0[si],'0'
inc si
loop convertScoreChar1
add levelChoice,'0'
mov ah, 40H
mov bx, handle
mov cx, 15
mov dx, offset scoreDigit0
int 21h

sub levelChoice,'0'
mov cx,4
mov si,0
convertScoreInt1:
sub scoreDigit0[si],'0'
inc si
loop convertScoreInt1

;file exit
mov ah, 3Eh
mov bx, handle
int 21h
ret
storeScore endp


;draws special item

drawSpecial proc uses ax bx cx dx
.if specialY<23 && levelChoice ==3
    mov ah, 6
    mov al, 0
    mov bh, 6    ;color
    mov ch, specialY     ;top row of window
    mov cl, 22     ;left most column of window
    mov dh, specialY    ;Bottom row of window
    inc dh
    mov dl, 22       ;Right most column of window
    int 10h
.endif
.if specialY==22 && paddleLeft<=22 
.if  paddleRight>= 22
mov makeslow,1
.endif
.endif
    ret
drawSpecial endp

disappearBricks proc uses ax bx cx dx
mov si,0
mov dh,0
mov cx,24; number of
mov bx,0;boundary line
mov dl,0

disappear:
.if bricks[si].health >0 && si != 16
inc disappearCounter
mov bl,bricks[si].health
add brickCounter,bl
mov ax, 10
mul bricks[si].health
add score,ax ;maintain score
mov bricks[si].health,0

.endif
.if disappearCounter>=5
mov disappearCounter,0
ret
.endif
add si,sizeof brick
loop disappear

ret
disappearBricks endp
exit:
mov ah, 4ch
int 21h
end