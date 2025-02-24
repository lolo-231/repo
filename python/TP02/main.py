#Alumnos: Cuello, Mirko Santino
#         Quattrini, Lorenzo

import flet as ft
from flet import alignment, colors
import random
import pygame

pygame.mixer.init()

sonido_tecla = pygame.mixer.Sound("resources/sonido.wav")
def crear_grilla(filas, columnas, ancho=35, alto=35, espacio=5):
    grilla = []
    for i in range(filas):
        fila = ft.Row(
            spacing=espacio,
            controls=[
                ft.Container(
                    width=ancho,
                    height=alto,
                    border=ft.border.all(2, ft.colors.BLACK),
                    bgcolor=ft.colors.GREY,
                    alignment=ft.alignment.center,
                    content=ft.Text("", color=ft.colors.BLACK, style=ft.TextStyle(weight=ft.FontWeight.BOLD))
                )
                for _ in range(columnas)
            ],
            alignment=ft.MainAxisAlignment.CENTER
        )
        grilla.append(fila)
    return grilla

def main(page):
    palabras = [
    "CASAS", "PERRO", "GATOS", "NIÑOS", "FLORA", "HUMOS", "LUCES", "MORAL", "PESOS", "RUEDA",
    "SUELO", "TIROS", "TOROS", "VENTA", "VERDE", "VUELO", "JUEGO", "LENTE", "PLAZA", "RATON",
    "TIGRE", "NIEVE", "NARIZ", "OJERA", "PATIO", "ROCAS", "SILLA", "PIANO", "NOCHE", "CARRO",
    "CIELO", "CABLE", "FUEGO", "GRANO", "HOJAS", "MANOS", "MANGO", "MONTE", "NIETA", "PRADO",
    "RAMOS", "SABIO", "SEÑAL", "SUEÑO", "TAPAS", "VASOS", "VISTA", "ZORRO", "CANTO", "CEBRA"
]
    palabra = random.choice(palabras)
    
    filas = 5
    columnas = 5
    grilla = crear_grilla(filas, columnas)
    texto = ""
    
    fila_activa = 0
    juego_terminado = False

    racha = 0  
    pistas_restantes=1
    
    contador_racha = ft.Text(f"Racha: {racha}", size=15, color=ft.colors.BLACK)

    contador_racha_container = ft.Container(
        width=100, 
        height=45,  
        bgcolor=ft.colors.GREEN,  
        border=ft.border.all(1, ft.colors.BLACK), 
        border_radius=ft.border_radius.all(10),  
        alignment=ft.alignment.center, 
        padding=10,  
        content=contador_racha,  
)


    def cambia_color(celda, color):
        
        celda.bgcolor = color
        celda.update()

    def colorea_fallido(intento, palabra, fila):
        intento_lista = list(intento)
        palabra_lista = list(palabra)

        for i, celda in enumerate(grilla[fila].controls):
            letra = celda.content.value
            if letra == palabra[i]:
                cambia_color(celda, colors.GREEN)
                celda.content.value = intento_lista[i]
                palabra_lista[i] = None
                intento_lista[i] = None

        for i, celda in enumerate(grilla[fila].controls):
            if intento_lista[i] is not None:
                if intento_lista[i] in palabra_lista:
                    cambia_color(celda, colors.YELLOW)
                    palabra_lista[palabra_lista.index(intento_lista[i])] = None
                else:
                    cambia_color(celda, colors.RED)

    def actualizar_grilla():
        nonlocal texto  
        if len(texto) == 1 and fila_activa < filas:
            for celda in grilla[fila_activa].controls:
                if celda.content.value == "":  
                    celda.content.value = texto
                    celda.update() 
                    texto = ""
                    return

    def boton_apretado(e):
        nonlocal texto
        texto = e.control.text
        sonido_tecla.play()
        actualizar_grilla()

    def usar_pista(e):
        nonlocal pistas_restantes
        if pistas_restantes > 0:
            # Encuentra la primera letra no adivinada en la palabra
            for i, letra in enumerate(palabra):
                celda = grilla[fila_activa].controls[i]
                if celda.content.value == "":
                    celda.content.value = letra
                    cambia_color(celda, colors.GREEN)
                    celda.update()
                    pistas_restantes -= 1
                    return
                
    def borrar():
    
        for celda in reversed(grilla[fila_activa].controls):
            if celda.content.value != "":
                celda.content.value = ""
                celda.update()
                return 

    def verificar_intento():
        nonlocal fila_activa, juego_terminado,racha
        letras_ingresadas = ""
        for celda in grilla[fila_activa].controls:
            letras_ingresadas += celda.content.value
        if len(letras_ingresadas) == 5:
            if letras_ingresadas == palabra:
                # ENCONTRADA
                for i, celda in enumerate(grilla[fila_activa].controls):
                    cambia_color(celda, colors.GREEN)
                juego_terminado = True

                racha+=1
                contador_racha.value = f"Racha: {racha}"
                contador_racha.update()

                boton_reiniciar()
            else:
                # NO ENCONTRADA
                colorea_fallido(letras_ingresadas, palabra, fila_activa)
            
            # Solo borra las letras si el juego no terminó
            if fila_activa < filas - 1:
                fila_activa += 1
            else:
                juego_terminado = True
                racha=0
                contador_racha.value = f"Racha: {racha}"
                contador_racha.update()
                boton_reiniciar()
                
            # Borra las letras en la siguiente fila solo si no terminó
            if not juego_terminado:
                for celda in grilla[fila_activa].controls:
                    celda.content.value = ""
                    celda.update()
                

    def boton_reiniciar():
        # Elimina cualquier botón de reinicio anterior (si existe)
        for control in page.controls:
            if isinstance(control, ft.ElevatedButton) and control.text == "Jugar de nuevo":
                page.controls.remove(control)
        
        reiniciar = ft.ElevatedButton("Jugar de nuevo", on_click=reiniciar_juego)
        page.add(reiniciar)
        reiniciar.update()

    def reiniciar_juego(e):
        nonlocal fila_activa, texto, juego_terminado, palabra,pistas_restantes
        fila_activa = 0
        texto = ""
        juego_terminado = False
        pistas_restantes = 1    
        palabra = random.choice(palabras)
        # Limpia la grilla
        for fila in grilla:
            for celda in fila.controls:
                celda.content.value = ""
                celda.bgcolor = colors.GREY
                celda.update()

        # Elimina el botón de reinicio después de jugar de nuevo
        for control in page.controls:
            if isinstance(control, ft.ElevatedButton) and control.text == "Jugar de nuevo":
                page.controls.remove(control)
                break  
        page.update()

    letras = [
        list("QWERTYUIOP"),
        list("ASDFGHJKL"),
        list("ZXCVBNM")
    ]   
    filas_teclado = []
    

    for i in range(len(letras)):
        fila = []
        for j in range(len(letras[i])):
            boton = ft.ElevatedButton(letras[i][j], on_click=boton_apretado,width=30,height=30,style=ft.ButtonStyle(padding=ft.Padding(0, 0, 0, 0)  # Elimina relleno interno
            )) 
            fila.append(boton)
        filas_teclado.append(ft.Row(controls=fila, alignment=ft.MainAxisAlignment.CENTER))

    teclado = ft.Column(controls=filas_teclado, alignment=ft.MainAxisAlignment.CENTER)
    
    boton_borrar = ft.ElevatedButton("<-", on_click=lambda e: borrar(),style=ft.ButtonStyle(padding=ft.Padding(0, 0, 0, 0), shape=ft.RoundedRectangleBorder(radius=5)),width=30, height=30)
    boton_verificar = ft.Row(
        controls=[ft.ElevatedButton("ENTER", on_click=lambda e: verificar_intento())],
        alignment=ft.MainAxisAlignment.CENTER
    )
    filas_teclado[-1].controls.insert(0,boton_borrar)
    filas_teclado[-1].controls.append(boton_verificar)

    boton_pista = ft.ElevatedButton("💡", on_click=usar_pista)

    page.add(
    ft.Column(
        controls=[
            
            ft.Row(controls=[contador_racha_container,boton_pista],alignment=ft.MainAxisAlignment.CENTER),
            ft.Column(
                controls=grilla,
                alignment=ft.MainAxisAlignment.CENTER,
                spacing=10,
            ),
            teclado,
        ],
        spacing=10,
        alignment=ft.MainAxisAlignment.START,  
    )
    )
# Ejecutar la app
ft.app(target=main)
