.8086
.model small
.stack 100h

.data
    salto db 0dh,0ah,24h
    textoCarFIN db "ingrese caracter de finalizacion",0dh,0ah,24h
    textolecturaini db "ingrese el texto",0dh,0ah,24h
    textomenu db "Menu:",0dh,0ah,"1-Muestra cantidad espacios",0dh,0ah, "2-Muestra cantidad parrafos",0dh,0ah,"3-Muestra cantidad caracteres",0dh,0ah,"4-Muestra cantidad numeros",0dh,0ah,"0-salir",0dh,0ah,24h

    lectura db 256 dup (24h)

    cantespacios db 0
    cantparrafos db 0
    lengt db 0
    nums db 0

    cantespaciosmostrar db "000$"
    cantparrafosmostrar db "000$"
    lengtmostrar db "000$"
    numsmostrar db "000$"

.code
extrn cargafunc:proc
extrn cargafuncnum:proc
extrn cuentocaracteres:proc
extrn imprimirtexto:proc
extrn regtoascii:proc
extrn asciitoreg:proc
extrn regtobin:proc

main proc
    mov ax, @data
    mov ds, ax

    mov bx, offset textoCarFIN
    call imprimirtexto

    mov ah, 1 ;pido caracter de finalizacion
	int 21h

	mov ah, al ; caracter de finalizacion en ah para cuentacaracteres
	mov cl, al
	xor ch,ch ; limpio parte alta de ch

    mov bx, offset textolecturaini
    call imprimirtexto
	; Caja de carga, pushear primero en ss:[bp+6] el offset de la variable a llenar, y luego pushear en ss:[bp+4] la parte baja el caracter de finalizacion
	push offset lectura
	push cx ; contiene caracter de finalizacion
	call cargafunc

	; entra en BX EL OFFSET DEL TEXTO CUYOS CARACTERES QUIERO CONTAR; En AH entra el caracter de finalizacion.; len en ch ; Contador de parrafo en CL, Contador de numeros en dh Y EN DL LOS ESPACIOS
	mov bx, offset lectura
	call cuentocaracteres

	mov cantespacios[0],dl
	mov cantparrafos[0],cl
	mov nums[0],dh
	mov lengt[0],ch

	;regtoascii
	;Recibe en BX el offset de la variable de texto en la que guardar el número (no más de 3 caracteres)
    ;Recibe en DL el número a convertir (no más de 255)

    mov bx, offset cantespaciosmostrar
    mov dl, cantespacios[0]
    call regtoascii
    mov bx, offset cantparrafosmostrar
    mov dl, cantparrafos[0]
    call regtoascii
    mov bx, offset numsmostrar
    mov dl, nums[0]
    call regtoascii
    mov bx, offset lengtmostrar
    mov dl, lengt[0]
    call regtoascii

    ;aca ya tengo todo convertido
    menu:
   		mov bx, offset textomenu
    	call imprimirtexto

    	mov ah, 1 ;pido caracter de menu
		int 21h

		cmp al, 2Fh
		jbe menu
		cmp al,'0'
		je finprograma
		cmp al,'1'
		je mostrarespacios
		cmp al,'2'
		je mostrarparrafos
		cmp al,'3'
		je mostrarlen
		cmp al,'4'
		je mostrarnumeros
		cmp al,'5'
		jae menu
mostrarespacios:
    mov bx, offset cantespaciosmostrar
    call imprimirtexto
    jmp menu
mostrarparrafos:
    mov bx, offset cantparrafosmostrar
    call imprimirtexto
    jmp menu
mostrarnumeros:
    mov bx, offset numsmostrar
    call imprimirtexto
    jmp menu
mostrarlen:
    mov bx, offset lengtmostrar
    call imprimirtexto
    jmp menu

finprograma:
	mov ax, 4c00h
	int 21h
main endp
end ;------------------------------------------------------------------------;EL END ESTA ACA WACHO THIS IS THE END

cargafunc proc; Caja de carga, pushear primero en ss:[bp+6] el offset de la variable a llenar, y luego pushear en la parte baja el caracter de finalizacion
	push bp
    mov bp,sp
    
    push ax
    push bx
    push cx
    
    mov bx,ss:[bp+6]; offset en bx
    mov cx,ss:[bp+4]; caracter de finalizacion en cl

carga:

	mov ah, 1 
	int 21h

	cmp al, cl
	je fincarga

	mov [bx], al
	inc bx

	jmp carga

fincarga:
	mov [bx], al ;guardo caracter de finalizacion
	pop cx
	pop bx
	pop ax
 	pop bp

	ret 4 
cargafunc endp

cuentocaracteres proc ; entra en BX EL OFFSET DEL TEXTO CUYOS CARACTERES QUIERO CONTAR; En AH entra el caracter de finalizacion.; len en ch ; Contador de parrafo en CL, Contador de numeros en dh Y EN DL LOS ESPACIOS
    
    mov cx, 0 ; inicio contadores
    mov dx, 0

    proceso:
    mov al, [bx]         ; Cargar el carácter

    cmp al, ah ; Fin de la cadena
    je fin

    cmp al, ' '
    je esespacio
    cmp al, 0dh
    je esparrafo
    cmp al, '0'
    je esnum
    cmp al, '1'
    je esnum
    cmp al, '2'
    je esnum
    cmp al, '3'
    je esnum
    cmp al, '4'
    je esnum
    cmp al, '5'
    je esnum
    cmp al, '6'
    je esnum
    cmp al, '7'
    je esnum
    cmp al, '8'
    je esnum
    cmp al, '9'
    je esnum

esrandom:
    inc bx
    inc ch	; len en ch
    jmp proceso

esespacio:
    inc dl ; contador de espacios en dl
    inc bx
    inc ch	; len en ch
    jmp proceso

esparrafo:
    inc cl ; Contador de parrafo en CL
    inc bx
    inc ch	; len en ch
    jmp proceso

esnum:
    inc dh ; Contador de numeros en dh
    inc bx
    inc ch	; len en ch
    jmp proceso


fin:

    ret
cuentocaracteres endp

imprimirtexto proc ; recibe en BX el offset del texto a imprimir (tiene que existir una variable global salto que sea 0dh,0ah,24h)
		push ax
		push dx
		mov ah,9
		mov dx, offset salto
		int 21h
		mov ah,9
		mov dx, bx
		int 21h
		pop dx
		pop ax
		ret
imprimirtexto endp

regtoascii proc
    ;Recibe en BX el offset de la variable de texto en la que guardar el número (no más de 3 caracteres)
    ;Recibe en DL el número a convertir (no más de 255)

    push ax
    push bx
    push dx

    xor ax, ax
    mov al, dl             ;Meto el numero en dl
    mov dl, 100            ;Divido AL por 100
    div dl                 ;AL = Resultado  Ah = Resto

    add [bx], al 		   ;Si N=abc, meto a en bx+0
    inc bx
 
    mov al, ah             ;Meto el resto en al
    xor ah, ah             
    mov dl, 10            
    div dl                 ;Si N=abc, divido bc por 10, me da al = b y ah = c como resto
    add [bx], al  		   ;Meto el resultado en bx+1
    inc bx  
    add [bx], ah           ;Meto el resto en bx+2

    pop dx
    pop bx
    pop ax

    ret

   regtoascii endp