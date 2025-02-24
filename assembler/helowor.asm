.8086
.model small
.stack 100h

.data
    texto db "Ingrese un texto y te dire cuantas consonantes y vocales tiene",0ah,0dh,'$'
    lectura db 255 dup (24h) ; Buffer de entrada
    consonantes db 0          ; Contador de consonantes
    vocales db 0              ; Contador de vocales
    espacios db 0
    consonantesNum db "000", 0ah, 0dh, 24h ; Cadena para mostrar las consonantes
    vocalesNum db "000", 0ah,0dh,24h     ; Cadena para mostrar las vocales
    espaciosNum db "000",0ah,0dh,24h
    r2a db 100, 10, 1          ; Factores de división para las posiciones decimales

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Mostrar mensaje inicial
    mov ah, 9
    mov dx, offset texto
    int 21h
    
    mov bx, offset lectura
    call cargafunc

    mov bx, offset lectura
    call cuentocaracteres

    ; Almacenar los contadores de consonantes y vocales
    mov vocales, cl
    mov consonantes, dh
    mov espacios, dl

;recibe el offset de una variable con 100 10 1 en bx, en AL el ascii del numero a convertir, y en si el offset de la variable a llenar 
    mov bx, offset r2a
    mov al, vocales
    mov si, offset vocalesNum
    xor ah,ah
    call r2afunc
    xor ah,ah
    mov bx, offset r2a
    mov al, consonantes
    mov si, offset consonantesNum

    call r2afunc
    xor ah,ah
    mov bx, offset r2a
    mov al, espacios
    mov si, offset espaciosNum

    call r2afunc
    ; Mostrar el número de vocales
    mov ah, 9
    mov dx, offset vocalesNum
    int 21h

    ; Mostrar el número de consonantes
    mov ah, 9
    mov dx, offset consonantesNum
    int 21h

    mov ah, 9
    mov dx, offset espaciosNum
    int 21h

    ; Terminar programa
    mov ax, 4C00h
    int 21h

main endp

cargafunc proc; Caja de carga, MOVER antes a BX el offset de la Variable a llenar
carga:
    mov ah, 1 
    int 21h
    cmp al, 0dh
    je fincarga
    mov [bx], al
    inc bx
    jmp carga
fincarga:
    ret
cargafunc endp



r2afunc proc
;recibe el offset de una variable con 100 10 1 en bx, en AL el ascii del numero a convertir, y en si el offset de la variable a llenar 
    mov cx,3

r2avocales:
    mov dl, [bx]
    div dl
    add al, 30h
    mov [si],al
    inc bx
    inc si
    mov al,ah
    xor ah,ah
    loop r2avocales
    ret
r2afunc endp

cuentocaracteres proc ; entra en BX EL OFFSET DEL TEXTO CUYOS CARACTERES QUIERO CONTAR; EN CL SALEN LAS VOCALES, EN DH LAS CONSONANTES Y EN DL LOS ESPACIOS
    mov ax, 0
    mov cx, 0
    mov dx, 0

    proceso:
    mov al, [bx]         ; Cargar el carácter

    cmp al, 24h ; Fin de la cadena
    je fin
    cmp al, 'A'
    je esvocal
    cmp al, 'E'
    je esvocal
    cmp al, 'I'
    je esvocal
    cmp al, 'O'
    je esvocal
    cmp al, 'U'
    je esvocal
    cmp al, 'a'
    je esvocal
    cmp al, 'e'
    je esvocal
    cmp al, 'i'
    je esvocal
    cmp al, 'o'
    je esvocal
    cmp al, 'u'
    je esvocal
    cmp al, ' '
    je esespacio
    cmp al, 'A'
    jb esrandom ; Si es menor que 'A', no es letra
    cmp al, 'Z'
    jbe esconsonante
    cmp al, 'a'
    jb esrandom
    cmp al, 'z'
    jbe esconsonante

esespacio:
    inc dl
    inc bx
    jmp proceso

esvocal:
    inc cl ; Contador de vocales en CL
    inc bx
    jmp proceso

esconsonante:
    inc dh ; Contador de consonantes en dh
    inc bx
    jmp proceso

esrandom:
    inc bx
    jmp proceso
fin:
    ret
cuentocaracteres endp
end
