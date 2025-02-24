.8086
.model small
.stack 100h

.data

    MSG7 db 0AH,0DH,0AH,0DH,0AH,0DH,' CONTROLES:'
      db 0AH,0DH,0AH,0DH,' W Para mover hacia arriba'
      db 0AH,0DH,0AH,0DH,' A Para mover hacia la izquierda'
      db 0AH,0DH,0AH,0DH,' D para mover hacia la derecha'
      db 0AH,0DH,0AH,0DH,' S para mover hacia abajo'
      db 0AH,0DH,0AH,0DH,' Enter para agregar celulas vivas'
      db 0AH,0DH,0AH,0DH,' Delete para eliminar celulas vivas'
      db 0AH,0DH,0AH,0DH,' Presiona P para iniciar el juego'
      db 0AH,0DH,0AH,0DH,0AH,0DH,0AH,0DH,0AH,0DH,0AH,0DH,0AH,0DH,0AH,0DH, "Presiona cualquier tecla para comenzar$"

    texto db 2000 dup (0);texto db 250 dup('X'), 250 dup(0), 250 dup('X'), 250 dup(0)
.code
main proc

    ; Inicializar segmento de datos
    mov ax, @data
    mov ds, ax

    mov ah, 0
    mov al, 2 ; Modo de texto 40x25
    int 10h 

    mov cx, 8014h ; aparece EL CURSOR
    mov ah, 1
    int 10h 


    lea si, texto ; escribo texto en pantalla (full ceros ahora)
    call escribirtexto

    call mover_en_pantalla

    mov cx, 2607h ; ESCONDER EL CURSOR
    mov ah, 1
    int 10h 

    
    mov cx, 9999h

gol:
        
    mov ah, 0
    int 16h ; Esperar por una tecla antes de salir
    cmp al, '.';tecla para salir
    je salir
    cmp al, ','
    je modificar
    call loop_juego ; SE ESCRIBE EL NUEVO TEXTO  

    lea si, texto ; escribo texto guardado
    call escribirtexto

    loop gol

modificar:
    mov cx, 8014h ; aparece EL CURSOR
    mov ah, 1
    int 10h 
    call mover_en_pantalla
    mov cx, 2607h ; ESCONDER EL CURSOR
    mov ah, 1
    int 10h 
    jmp gol
salir:
    mov ax, 4c00h
    int 21h
main endp

escribirtexto proc ;ES UNA FUNCION QUE ESCRIBE UN TEXTO DE 1000 CARACTERES EN PANTALLA
    push ax
    push bx
    push dx
    push cx

    mov dh, 0   ; Fila
    mov dl, 0   ; Columna
    mov ah, 2   ;modo Ajustar cursor
    mov bh, 0 ; pagina
    int 10h ;  seteo cursor en 0,0
    mov cx, 1

escribir_loop:
    mov al, [si] ; Leer el carácter de texto en [si]
    inc si       ; Avanzar a la siguiente posición

    mov ah, 0Ah  ; Modo Imprimir carácter c color
    mov bh, 0    ; Página
    int 10h      ; imprime carácter de al

    ; Mover el cursor manualmente
    add dl, 1
    cmp dl, 80
    jne continuar
    ; Salto a nueva línea
    mov dl, 0
    add dh, 1
    cmp dh, 25
    je finfunc

continuar:
    ; Ajustar cursor
    mov ah, 2
    mov bh, 0    ; Página
    int 10h

    jmp escribir_loop
finfunc:
    pop cx
    pop dx
    pop bx
    pop ax
    ret
escribirtexto endp


contarvec1 proc ;ENTRAN DH Y DL COMO PARAMETROS ; salen en CH el caracter de la posicion, y en cl la cantidad de vecinos
    
    push ax
    push bx
    push dx

    mov ah, 2 ;esto es para guardar el caracter en ch
    mov bh, 0
    int 10h

    mov ah, 8
    mov bh, 0
    int 10h ; hasta aca

    mov ch, al ; en ch esta el caracter de la coordenada dh,dl

    xor bl, bl    ; Contador de paso en BL
    xor cl, cl    ; Contador de vecinos en CL

    push dx
    push dx
    push dx
    push dx
    push dx
    push dx
    push dx
    push dx

comparo_bl:

    cmp bl, 8
    je finfun
    
    pop dx
          ; Guarda la posición original de DX

    ; Determinar dirección basada en BL

    call direccion  ; Llama al subprocedimiento para ajustar DH y DL según la dirección en BL
    call ajustar_limites
    ; Validar límites de la cuadrícula y ajustar si es necesario

    ; Mover el cursor a la nueva posición
    mov ah, 2
    mov bh, 0
    int 10h

    ; Leer el carácter en la posición ajustada
    mov ah, 8
    mov bh, 0
    int 10h


    cmp al,2 ;CAMBIAR ACA EL CARACTER DE VIVO
    jne noesUno

    inc cl       ; Incrementar contador de vecinos

noesUno:
    inc bl       ; Incrementa el paso
    jmp comparo_bl

finfun:

    pop dx
    pop bx
    pop ax

    ret

; Subprocedimiento para ajustar DH y DL según la dirección en BL
direccion:
    cmp bl, 0
    je abajo
    cmp bl, 1
    je abajo_derecha
    cmp bl, 2
    je derecha
    cmp bl, 3
    je arriba_derecha
    cmp bl, 4
    je arriba
    cmp bl, 5
    je arriba_izquierda
    cmp bl, 6
    je izquierda
    cmp bl, 7
    je abajo_izquierda
    ret

abajo: 
    inc dh
    ret
abajo_derecha:
    inc dh
    inc dl
    ret
derecha:
    inc dl
    ret
arriba_derecha:
    dec dh
    inc dl
    ret
arriba:
    dec dh
    ret
arriba_izquierda:
    dec dh
    dec dl
    ret
izquierda:
    dec dl
    ret
abajo_izquierda:
    inc dh
    dec dl
    ret


ajustar_limites:
    ; Manejar fila (dh)
    cmp dh, 25      ; Verifica si dh es mayor o igual a 25
    je reset_fila0 ; Si sí, vuelve a la fila 0
prim:
    cmp dh, 255     ; Verifica si dh es negativo
    je reset_fila24 ; Si es negativo, vuelve a la última fila (24)
segu:
    ; Manejar columna (dl)
    cmp dl, 80      ; Verifica si dl es mayor o igual a 40
    je reset_col0  ; Si sí, vuelve a la columna 0
terc:
    cmp dl, 255    ; Verifica si dl es negativo
    je reset_col39  ; Si es negativo, vuelve a la última columna (39)
    ret

reset_fila0:
    mov dh, 0
    jmp prim
reset_fila24:
    mov dh, 24
    jmp segu
reset_col0:
    mov dl, 0
    jmp terc
reset_col39:
    mov dl, 79
    ret
contarvec1 endp

loop_juego proc ; debe recorrer la pantalla, armando un texto, que contenga 1 para los vivos y 2 para los muertos. texto[si]
    
    xor si,si
    push ax
    push bx
    push dx
    push cx

    mov dh, 0   ; Fila
    mov dl, 0   ; Columna


loopgol:
    call contarvec1 ; en dh y dl entran las coord y en ch sale el caracter y en cl salen los vecinos

    cmp ch, 2 ;cambiar ACA EL CARACTER DE VIVO
    je vivo
    jmp muerto
    
vivo:
    cmp cl,2
    je celulaviva
    cmp cl,3
    je celulaviva
    jmp celulamuerta
muerto:
    cmp cl,3
    jne celulamuerta
    jmp celulaviva



celulaviva:
    mov texto[si],2 ;CAMBIAR ACA EL CARACTER DE VIVO
    jmp ajusto_pos
celulamuerta:
    mov texto[si],0 ;CAMBIAR ACA EL CARACTER DE MUERTO
    jmp ajusto_pos


ajusto_pos:
    inc si
    add dl, 1
    cmp dl, 80
    jne continuar1
    mov dl, 0 ;reinicia contador columnas
    add dh, 1 ;salta a la nueva linea
    cmp dh, 25
    je finfunc1

continuar1:
    jmp loopgol
finfunc1:
    pop cx
    pop dx
    pop bx
    pop ax
    ret
loop_juego endp

mover_en_pantalla proc ; mueve el cursor en la pantalla  
    push ax
    push bx
    push dx
    push cx

   
    mov cx,1 ;cantidad de veces que imprime

    xor dx,dx
    mov ah, 2
    mov bh, 0 ; page
    int 10h   ; seteo cursor en 0

    pidoletra:
        mov ah,00                            ;AH = ??   Scan-code de la tecla pulsada                          
        int 16h ; pido una letra del teclado; AL = ?? Caracter ASCII de la tecla pulsada
        cmp al, 0dh; con enter escribis letra
        je esenter
        cmp al, 08h
        je delete

        cmp al, 'p' ;con p le das play
        je finfuncion

        call comparoletras
        call ajustar_limites ;LLAMO AL MISMO DE LA OTR PORQUE FUNCIONA JAJA

            ; Mover el cursor a la nueva posición
        mov ah, 2
        int 10h

        jmp pidoletra

esenter:
    mov al, 2 ;CAMBIAR ACA EL CARACTER DE VIVO
    mov ah, 0Ah
    int 10h
    jmp pidoletra
delete:
    mov al ,0 ;CAMBIAR ACA EL CARACTER DE MUERTO
    mov ah,0Ah
    int 10h
    jmp pidoletra

finfuncion:
    pop cx
    pop dx
    pop bx
    pop ax
    ret


comparoletras:
    cmp al ,'a'
    je izqcursor
    cmp al, 'w'
    je arribacursor
    cmp al, 'd'
    je derechacursor
    cmp al, 's'
    je abajocursor
    ret
izqcursor:
    dec dl
    ret
arribacursor:
    dec dh
    ret
abajocursor:
    inc dh
    ret
derechacursor:
    inc dl
    ret

mover_en_pantalla endp

menu_ayuda proc
    call limpiar_pantalla
    mov ah, 0
    mov al, 0
    int 10h
    mov ah, 9
    lea dx, msg7
    int 21h
    mov ah, 0 
    int 16h
    ret
menu_ayuda endp

limpiar_pantalla proc 
    
    mov ah,0
    mov al,2
    int 10h
    mov ax, 13h
    int 10h
    
    ret

limpiar_pantalla endp 

end



