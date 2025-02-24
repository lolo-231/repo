# -*- coding: utf-8 -*-
"""
Editor de Spyder

Este es un archivo temporal.
"""
import random
import numpy as np
def crear_album(figus_total):
    album=[]
    for x in range(0,figus_total):
        album.append(0)
    return album

def hay_alguno(l,e):
    i=0
    while i<len(l):
        if l[i]==e:
            return True
        elif l[i]!=e:
           i=i+1
    return False    
        
def comprar_una_figu(figus_total):
    a=random.randint(0,figus_total-1)
    return a

def cuantas_figus(x):
    album=crear_album(x)
    esta_vacio=hay_alguno(album,0)
    contador=0
    while esta_vacio:
        a=comprar_una_figu(len(album))
        album[a]=1
        contador=contador+1
        esta_vacio=hay_alguno(album,0)
    return contador

def promedio(n_rep,figus_total):
    p=0
    for k in range(0,n_rep):
        a=cuantas_figus(figus_total)
        p=p+a 
    w=p/n_rep
    return w

def experimentar(n_rep,figus_total):
    d=[]
    for q in range(0,n_rep):
        o=cuantas_figus(figus_total)
        d.append(o)
    return d



#con 6 da 14,896
#con 670 da 4692.87 el promedio

def generar_paquete(figus_total,figus_paquete):
    a=[]
    for e in range(0,figus_paquete):
        l=random.randint(0,figus_total)
        a.append(l)
    return a

def cuantos_paquetes(figus_total,figus_paquete):
    album=crear_album(figus_total)
   
    contador=0
    i=0
    while hay_alguno(album,0):
        f=generar_paquete(figus_total,figus_paquete)
        i=0
        while i<len(f):
            album[f[i]-1]=1
            i=i+1
            contador=contador+1/figus_paquete
    return contador

def experimentar_con_paquetes(figus_total,figus_paquete,n_rep):
    p=[]
    for ñ in range(0,n_rep):
        p.append(cuantos_paquetes(figus_total,figus_paquete))
    q=np.mean(p)
    return q

resultado_final=experimentar_con_paquetes(670,5,100)  
