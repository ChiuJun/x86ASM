jmp near start

data1 db 0x05,0xff,0x80,0xf0,0x97,0x30
data2 dw 0x90,0xfff0,0xa0,0x1235,0x2f,0xc0,0xc5bc
negInfo db 'd','a','t','a','1',':',0,'d','a','t','a','2',':',0

start:
    mov ax,0x07c0
    mov ds,ax

    mov ax,0xb800
    mov es,ax

    mov cx,6
    mov dx,0
    mov si,data1
counter1:
    mov al,[si]
    cmp al,0
    jge pos1
    inc dx
    pos1:
    inc si
    loop counter1

    mov cx,7
    mov bx,0
    mov si,data2
counter2:
    mov ax,[si]
    cmp ax,0
    jge pos2
    inc bx
    pos2:
    add si,2
    loop counter2

    add dx,0x30
    add bx,0x30
    mov si,negInfo
    mov [si+6],dl
    mov [si+13],bl

    mov cx,14
    mov di,0
    show:
        mov al,[si]
        mov ah,0x04
        mov [es:di],ax
        add di,2
        inc si
    loop show
    
    jmp near $

    times 510-($-$$) db 0
    db 0x55,0xaa
    