# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 15:35:49 2020

@author: lorenzo
"""

import random
import numpy as np
import matplotlib.pyplot as plt

def generar_bosque(n):
    bosque=[]
    for m in range(n):
        bosque.append(0)
    return bosque

def suceso_aleatorio(p):
    a=random.random()
    if a<=p:
        return True
    else:
        return False

def brotes(bosque,p):
    i=0
    for k in range (len(bosque)):
        l=suceso_aleatorio(p)
        if l:
            bosque[i]=1
            i=i+1
        else:
            i=i+1
    return bosque

def cuantos(bosque, tipo_celda):
    m=bosque.count(tipo_celda)
    return m

def rayos(bosque,f):
    i=0
    for k in range(len(bosque)):
        l=suceso_aleatorio(f)
        if l and bosque[i]==1:
            bosque[i]=-1
            i=i+1
        else:
            i=i+1
    return bosque

def propagacion(bosque):
    i=0
    while i<(len(bosque)-1):
        if bosque[i]==-1:
            if bosque[i+1]==1:
                bosque[i+1]=-1        
            else:
                i=i+1
        else:i=i+1
    while i>0:
        if bosque[i]==-1:
            if bosque[i-1]==1:
                bosque[i-1]=-1        
            else:
                i=i-1
        else:i=i-1
    return bosque

def limpieza(bosque):
    i=0
    while i<len(bosque):
        if bosque[i]==-1:
            bosque[i]=0
            i=i+1
        else:
            i=i+1
    return bosque

def dinamica(n,n_rep,p,f):
    a=[]
    bosque=generar_bosque(n)
    for s in range(0,n_rep):
        bosque=brotes(bosque,p)
        bosque=rayos(bosque,f)
        bosque=propagacion(bosque)
        bosque=limpieza(bosque)
        a.append(cuantos(bosque,1))
    return a

def dinamica_promedio(n,n_rep,p,f):
    a=[]
    bosque=generar_bosque(n)
    for s in range(0,n_rep):
        bosque=brotes(bosque,p)
        bosque=rayos(bosque,f)
        bosque=propagacion(bosque)
        bosque=limpieza(bosque)
        a.append(cuantos(bosque,1))
    w=np.mean(a)
    return w

def promedio_brotes(n,n_rep,p,f):
    a=[]
    while p<=1:
        a.append(dinamica_promedio(n,n_rep,p,f))
        p=p+0.01
    return a

ejex=np.arange(100)
ejey=promedio_brotes(100,100,0,0.02)
plt.title("grafico del bosque segun la chance de brote")
plt.plot(ejex,ejey)