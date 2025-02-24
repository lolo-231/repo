.8086
.model small
.stack 100h

.data
		salto db 0dh,0ah,24h
.code

public cargafunc
public cargafuncnum
public cuentocaracteres
public imprimirtexto
public regtoascii
public asciitoreg
public regtobin

 
cargafunc proc; Caja de carga, pushear primero en ss:[bp+6] el offset de la variable a llenar, y luego pushear en ss:[bp+4]la parte baja el caracter de finalizacion
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
;------------------------------------------------------------------;
cargafuncnum proc; Caja de carga, MOVER antes a BX el offset de la Variable a llenar ;si todo esta bien llena una variable de tres nums en el orden correcto de ingreso
	push ax
	push cx
	mov cx, 0
	mov ax, 0
cargan:
	mov ah, 1 
	int 21h

	cmp al, 0dh	
	je fincargan

	push ax
	inc cx
	jmp cargan
fincargan:
	cmp cx,1
	je unoSolo
	cmp cx,2
	je sonDos
	cmp cx,3
	je sonTres
unoSolo:
	pop ax
	mov [bx+2],al
	jmp finverdadero
sonDos:
	pop ax
	mov [bx+2],al
	pop ax
	mov [bx+1],al
	jmp finverdadero
sonTres:
	pop ax
	mov [bx+2],al
	pop ax
	mov [bx+1],al
	pop ax
	mov [bx],al
finverdadero:
	pop cx
	pop ax
	ret
cargafuncnum endp
;------------------------------------------------------------------;
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
;------------------------------------------------------------------;
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
;------------------------------------------------------------------;
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
;------------------------------------------------------------------;
asciitoreg proc ;RECIBE EN BX EL OFFSET DE UNA VARIABLE DE 3 DIGITOS ASCII Y DEVUELVE EN CL LA CANTIDAD NUMERICA

        push ax
        push bx
        push dx

        mov cx, 0
        sub [bx], 30h 
        mov al, [bx]  
        mov dl, 100
        mul dl 
        add cl, al 

        inc bx
        sub [bx], 30h
        mov al, [bx]
        mov dl,10
        mul dl
        add cl,al

        inc bx
        sub [bx], 30h
        add cl, [bx]

        pop dx
        pop bx
        pop ax

        ret
asciitoreg endp
;------------------------------------------------------------------;
regtobin proc ; pushea primero el offset de la variable a llenar en ss:bp+6 y el numero binario de 8 bits en la parte baja de ss:bp+4
        push bp
        mov bp,sp

        push bx
        push cx
        push si

        mov cx, ss:[bp+4] ; Lee el número binario en CX (CL)
        mov bx, ss:[bp+6] ; Lee el offset en BX
        mov si, 0

uno:    cmp si, 8  
        je afuera
        shl cl, 1 
        jnc esCero 
        mov [bx], '1'
        inc bx
        inc si
        jmp uno
esCero:         
        mov [bx], '0'
        inc bx
        inc si
        jmp uno

afuera: 
        mov [bx], '$'
        pop si
        pop cx
        pop bx

        pop bp
        ret 4
regtobin endp
;------------------------------------------------------------------;

	regtoascii_stack proc
		;Recibe el offset de la variable en donde guardar el ascii (pusheo primero [ss:bp+6])
		;Recibe el numero a convertir (No más de 255) (pusheo segundo [ss:bp+4])
		
		push bp
		mov bp,sp

		push ax
		push bx
		push dx

		mov ax,[ss:bp+4]		;Meto en AX el número a modificar
		mov bx,[ss:bp+6]		;Meto en BX el offset para trabajar con él

    	           
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

    	pop bp
    	ret 4
	regtoascii_stack endp	
;------------------------------------------------------------------;

	asciitoreg_stack proc
		;Recibe unicamente el offset de una variable de texto [ss:bp+4] y
		;devuelve en CX(cl) el resultado numérico
		
		push bp
		mov bp,sp

		push ax
		push bx

		xor cx,cx
		xor ax,ax
		mov bx,[ss:bp+4]    
		mov si,3   ;Lo uso como contador
		vueltaa2rs:
	       	mov al,[bx]    ;meto en al el primer digito
			push ax        ;guardo el valr de ax en el stack
			mov al,cl      ;meto cl (primer vuelta es 0) en al
			mov dl,10
			mul dl		   ;al x 10
			mov cl,al      ;meto el resultado en cl
			pop ax         ;recupero el antiguo valor de al
			sub al,30h     ;le resto 30h para pasarlo de ascii a número
			add cl,al      ;le agrego a cl el número correspondiente
			dec si
			cmp si,0       
			je fina2rs     
			inc bx
		jmp vueltaa2rs

		fina2rs:

		pop ax
		pop bx

		pop bx

		ret 2
	asciitoreg_stack endp
;------------------------------------------------------------------;
end ;asi terminamos la libreria
