       ;想起来再写
       mov eax,cs      
       mov ss,eax
       mov sp,0x7c00

       mov eax,[cs:pgdt+0x7c00+0x02]      ;GDT的32位线性基地址 
       xor edx,edx
       mov ebx,16
       div ebx                            ;分解成16位逻辑地址 

       mov ds,eax                         ;令DS指向该段以进行操作
       mov ebx,edx                        ;段内起始偏移地址 

       ;0# NULL
       mov dword [ebx+0x00],0x00000000
       mov dword [ebx+0x04],0x00000000  

       ;1# DATA segment 0x0010_0000--0x001F_FFFF 1MB
       mov dword [ebx+0x08],0x0000ffff
       mov dword [ebx+0x0c],0x004f9210

       ;2# CODE segment
       mov dword [ebx+0x10],0x7c0001ff    ;基地址为0x00007c00，512字节 
       mov dword [ebx+0x14],0x00409800    

       ;3# DATA segment alias for 2#
       mov dword [ebx+0x18],0x7c0001ff
       mov dword [ebx+0x1c],0x00409200
       
       ;4# STACK segment
       mov dword [ebx+0x20],0x7c00fffe
       mov dword [ebx+0x24],0x00cf9600
       
       ;5# DATA segment 0xb800
       mov dword [ebx+0x28],
       mov dword [ebx+0x2c],

       mov word [cs: pgdt+0x7c00],47

       lgdt [cs: pgdt+0x7c00]

       in al,0x92                         
       or al,0000_0010B
       out 0x92,al                        ;打开A20

       cli                                
       
       ;set PE
       mov eax,cr0
       or eax,1
       mov cr0,eax                        

       jmp dword 0x0010:flush             ;16位的描述符选择子：32位偏移
                                          
       [bits 32]                          
flush:                                     
       mov eax,0x0008                      
       mov ds,eax

       mov eax,0x0018                     
       mov es,eax
       mov fs,eax
       mov gs,eax

       mov eax,0x0020                     ;0000 0000 0010 0000
       mov ss,eax
       xor esp,esp                        ;ESP <- 0

       mov dword [es:0x0b8000],0x072e0750 ;字符'P'、'.'及其显示属性
       mov dword [es:0x0b8004],0x072e074d ;字符'M'、'.'及其显示属性
       mov dword [es:0x0b8008],0x07200720 ;两个空白字符及其显示属性
       mov dword [es:0x0b800c],0x076b076f ;字符'o'、'k'及其显示属性

       ;开始冒泡排序 
       mov ecx,pgdt-string-1              ;遍历次数=串长度-1 
@@1:
       push ecx                           ;32位模式下的loop使用ecx 
       xor bx,bx                          ;32位模式下，偏移量可以是16位，也可以 
@@2:                                      ;是后面的32位 
       mov ax,[string+bx] 
       cmp ah,al                          ;ah中存放的是源字的高字节 
       jge @@3 
       xchg al,ah 
       mov [string+bx],ax 
@@3:
       inc bx 
       loop @@2 
       pop ecx 
       loop @@1

       mov ecx,pgdt-string
       xor ebx,ebx                        ;偏移地址是32位的情况 
@@4:                                      ;32位的偏移具有更大的灵活性
       mov ah,0x07
       mov al,[string+ebx]
       mov [es:0xb80a0+ebx*2],ax          ;演示0~4GB寻址。
       inc ebx
       loop @@4

       hlt 

;-------------------------------------------------------------------------------
;fill data 0x55AA55AA 0xAA55AA55
data   db 0x55AA55AA
;1,048,576 
buffer dd 0
;-------------------------------------------------------------------------------
pgdt   dw 0
       dd 0x00007e00      ;GDT的物理地址
;-------------------------------------------------------------------------------                             
times 510-($-$$)     db 0
                     db 0x55,0xaa