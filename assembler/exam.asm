.8086
.model small
.stack 100h
.data
	
	salto db 0dh,0ah,24h
	textocant1 db "INGRESE CANTIDAD DEL CARACTER 1",0dh,0ah,24h
	textocar1 db  "INGRESE EL CARACTER 1",0dh,0ah,24h

	textocant2 db "INGRESE CANTIDAD DEL CARACTER 2",0dh,0ah,24h
	textocar2 db "INGRESE EL CARACTER 2",0dh,0ah,24h

	cant1 db "000",0dh,0ah,24h
	cant1a db 0
	car1 db "0",0dh,0ah,24h

 	cant2 db "000",0dh,0ah,24h
 	cant2a db 0
 	car2 db "0",0dh,0ah,24h

 	datamul db 100,10,1
.code

main proc
	mov ax,@data
	mov ds,ax

	;imprimo texto cant 1
		mov bx, offset textocant1
		call imprimirtexto
	;cargacant1:
		mov bx, offset cant1
		call cargafuncnum
		mov bx, offset cant1
		call imprimirtexto
	;imprimo texto car 1
		mov bx, offset textocar1
		call imprimirtexto
	;cargacar1:
		mov bx, offset car1
		call cargafunc
	
	;imprimo texto cant 2
		mov bx, offset textocant2
		call imprimirtexto

	;cargacant2:
		mov bx, offset cant2
		call cargafuncnum
		mov bx, offset cant2
		call imprimirtexto
	;imprimo texto car 2	
		mov bx, offset textocar2	
		call imprimirtexto

	;cargacar2:
		mov bx, offset car2
		call cargafunc

;asciitoreg_stack ----Recibe unicamente el offset de una variable de texto [ss:bp+4] y
		;devuelve en CX(cl) el resultado numérico
	a2r:
		mov bx, offset cant1
		push bx
		call asciitoreg_stack
		mov cant1a,cl
		mov ah,2
		mov dl,cl
		int 21h
	a2r2:
		mov bx, offset cant2
		push bx
		call asciitoreg_stack
		mov cant2a,cl
		mov ah,2
		mov dl,cl
		int 21h

mov cl, cant1a
armotexto1:
	mov ah,2
	mov dl,car1[0]
	int 21h
	loop armotexto1


mov cl,cant2a
armotexto2:
	mov ah,2
	mov dl,car2[0]
	int 21h
	loop armotexto2

	finreal:
	mov ax,4c00h
	int 21h

main endp 


cargafuncnum proc; Caja de carga, MOVER antes a BX el offset de la Variable a llenar
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

a2rfunc proc ;recibe el offset de una variable con 100 10 1 en BX, en AL el ascii del numero a convertir, y en SI el offset de la variable a llenar 
	mov cx,3

proceee:
	mov dl, [bx]
	div dl
	add al, 30h
	mov [si],al
	inc bx
	inc si
	mov al,ah
	xor ah,ah
loop proceee
	ret
a2rfunc endp

r2afunc proc ;recibe en SI el offset de la variable a convertir, en BX el offset de una variable con 100 10 1, y el ascii sale por dh
	mov cx,3
		proce:
		mov al,[si]
		sub al, 30h
		mov dl,[bx]
		mul dl
		add dh,al
		inc bx
		inc si
		xor ah,ah
		loop proce
	ret
r2afunc	endp

imprimirtexto proc ; recibe en BX el offset del texto a imprimir (tiene que existir una variable global salto que sea 0dh,0ah,24h)
		push ax
		push dx
		mov ah,9
		mov dx, bx
		int 21h
		pop dx
		pop ax
		ret
imprimirtexto endp

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
		mov si,3  		   ;Lo uso como contador
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
end