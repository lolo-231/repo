#ifndef MI_LIBRERIA_H_INCLUDED
#define MI_LIBRERIA_H_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "mi_libreria.h"
#define ARCHIVO_COMP_TXT "corredores_v1.txt"
#define ARCHIVO_COMP_BINARIO "competidores.dat"
// Definición de las estructuras
struct fecha {
    int dia;
    char mes[4];
    int ano;
};

struct datacomp {
    int orden;
    int corredor;
    struct fecha fechas;
    int edad;
    char pais[4];
    float tiempo;
    int activo;
};

FILE *creo_archivo_Bin(){
    FILE *archivoBinario;
    archivoBinario = fopen(ARCHIVO_COMP_BINARIO, "wb");
    if (archivoBinario == NULL) {
        printf("error al abrir el archivo binario\n");
        return;
    }
    return archivoBinario;}

void lleno_datacomp(char *linea,struct datacomp *competidor){//es una funcion que usa strtok para separar la linea leida y correctamente llenar el struct datacomp menos el campo activo
    char *token;
    token=strtok(linea,";");
    if (token != NULL) competidor->orden = atoi(token);
    token = strtok(NULL, ";");
    if (token != NULL) competidor->corredor = atoi(token);
    token = strtok(NULL, ";");
    if (token != NULL) competidor->fechas.dia = atoi(token);
    token = strtok(NULL, ";");
    if (token != NULL) strncpy(competidor->fechas.mes, token, 3);
    for (int i = 0; i < 3; i++) { //para cambiar las fechas del mes a mayus
            if(competidor->fechas.mes[i]>='a'&& competidor->fechas.mes[i] <= 'z'){
            competidor->fechas.mes[i]=competidor->fechas.mes[i]-32;}
        }
    competidor->fechas.mes[3] = '\0'; //para que se guarde bien en el archivo binario
    token = strtok(NULL, ";");
    if (token != NULL) competidor->fechas.ano = atoi(token);
    token = strtok(NULL, ";");
    if (token != NULL) competidor->edad = atoi(token);
    token = strtok(NULL, ";");
    if (token != NULL) strncpy(competidor->pais, token, 3);
    competidor->pais[3] = '\0'; //para que se guarde bien en el archivo binario
    token = strtok(NULL, ";");
    if (token != NULL) competidor->tiempo = atof(token);
    token = strtok(NULL, ";");
    if (token != NULL) competidor->activo = atoi(token);
    return;
}



void listar_txt(const char nombre_archivo_txt[30]){
    FILE *archivoTexto;
    char linea[100];
    struct datacomp corredor;
    archivoTexto = fopen(nombre_archivo_txt,"r");

    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo de texto\n");
        return;}

    printf("Orden\tCorredor\tDia\tMes\tAño\tEdad\tPais\tTiempo\t\tActivo\n");
    while(fgets(linea,sizeof(linea),archivoTexto)!=NULL){ //leo cada linea del archivo, para cada una de las lineas lleno el struct datacomp, y finalmente lo imprimo
        lleno_datacomp(linea,&corredor);
        printf("%d\t%d\t\t%d\t%s\t%d\t%d\t%s\t%.6f\t%d \n",
               corredor.orden,
               corredor.corredor,
               corredor.fechas.dia,
               corredor.fechas.mes,
               corredor.fechas.ano,
               corredor.edad,
               corredor.pais,
               corredor.tiempo,
               corredor.activo);
        }
        fclose(archivoTexto);
    }

void migrar_datos(){
    FILE *archivoTexto, *archivoBinario;
    struct datacomp corredor;
    char linea[100]; //guardo lo leido en esta variable
    //abro ambos archivos
    archivoTexto = fopen(ARCHIVO_COMP_TXT, "r");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo de texto\n");
        return;
    }
    archivoBinario = creo_archivo_Bin();

    // Leer cada línea del archivo de texto, guardarlo en el struct y escribir en el archivo binario

    while (fgets(linea,sizeof(linea),archivoTexto)!=NULL){
        lleno_datacomp(linea,&corredor);
        if (corredor.activo!=0){
            corredor.activo=1;
        }
        else{
            corredor.activo=0;
        }
        fwrite(&corredor, sizeof(struct datacomp), 1, archivoBinario);
    }

    // Cerrar los archivos
    fclose(archivoTexto);
    fclose(archivoBinario);

    printf("Los datos han sido migrados exitosamente.\n");
    return ;
}

int menu_listar_dat() {
    int num;
    int flag = 0;
    printf("Que competidores quiere listar? \n 1-Todos\n 2-Solo Activos\n 3-Por Pais\n 4-Por Tiempo \n Ingrese el numero de la opcion que desee: ");

    while (flag == 0) {
        scanf("%d", &num);
        if (num < 1 || num > 4) {
            printf("Ingrese un numero valido (1-4) \n");
            fflush(stdin);
        } else {
            flag = 1; // si la opción es válida, salimos del bucle
        }
    }
    return num;
}

void listar_dat(){
    FILE *archivoBinario = fopen(ARCHIVO_COMP_BINARIO, "rb");
    if (archivoBinario == NULL) {
        printf("Error al abrir el archivo binario para leer");
        return;
    }

    struct datacomp corredor;

    int mostrar; //variable que al final si cumple las condiciones uso para saber si se muestra o no
    char pais[4];
    float maxT, minT;
    int menu=menu_listar_dat();

    switch(menu){
    case 1:
        printf("Listando todos los corredores:\n");
        break;
    case 2:
        printf("Listando solo los corredores activos:\n");
        break;
    case 3:
        printf("Ingrese el pais: "); // Me aseguro de que cuando se guarde el pais, se guarda con el codigo y en mayusculas
        scanf("%s", pais);
        for (int i = 0; i < 3; i++) {
            if(pais[i]>='a'&& pais[i] <= 'z'){
                pais[i]=pais[i]-32;
            }
        }
        pais[3] = '\0';
        printf("Listando corredores de %s:\n", pais);
        break;
    case 4:
        printf("Ingrese rango de tiempo (primero el minimo, despues el maximo) \n");
        scanf("%f",&minT);
        fflush(stdin);
        scanf("%f",&maxT);
        printf("Listando corredores con tiempos entre %.6f y %.6f \n",minT, maxT);
        break;
    }

    printf("Orden\tCorredor\tDia\tMes\tAño\tEdad\tPais\tTiempo\t\tActivo\n");
    while (fread(&corredor, sizeof(struct datacomp), 1, archivoBinario)==1){  //recorro cada corredor aplicando los filtros necesarios para saber si se muestra o no
        mostrar=1; // la opcion 1 muestra todos

        //aplico los filtros
        if(menu ==2 && corredor.activo==0){ // solo los activos
            mostrar=0;
        }
        if(menu==3 && (strcmp(corredor.pais,pais)!= 0)){ //strcmp devuelve 0 si y solo si ambas cadenas son iguales (si son diferentes no los muestro)
            mostrar=0;
        }
        if(menu==4 && (corredor.tiempo<minT || corredor.tiempo>maxT)){ //ambos limites
            mostrar=0;
        }
        if (mostrar==1){ //solo muestra los que no fueron filtrados
        printf("%d\t%d\t\t%d\t%s\t%d\t%d\t%s\t%.6f\t%d \n",
               corredor.orden,
               corredor.corredor,
               corredor.fechas.dia,
               corredor.fechas.mes,
               corredor.fechas.ano,
               corredor.edad,
               corredor.pais,
               corredor.tiempo,
               corredor.activo);}
    }
    return;
    fclose(archivoBinario);
}

int check_validez(struct datacomp competidor){
    int error=0;
    if(competidor.corredor<=0){
        error=1;
        printf("Id de corredor invalida \n");
    }
    if(competidor.orden<=0){
        error=1;
        printf("Numero de orden invalido \n");
    }
    if(competidor.fechas.ano<2014 || competidor.fechas.ano>2024){
        error=1;
        printf("Año invalido \n");
    }
    if(!(strcmp(competidor.fechas.mes, "ENE") == 0 || strcmp(competidor.fechas.mes, "FEB") == 0 || strcmp(competidor.fechas.mes, "MAR") == 0 ||
        strcmp(competidor.fechas.mes, "ABR") == 0 || strcmp(competidor.fechas.mes, "MAY") == 0 || strcmp(competidor.fechas.mes, "JUN") == 0 ||
        strcmp(competidor.fechas.mes, "JUL") == 0 || strcmp(competidor.fechas.mes, "AGO") == 0 || strcmp(competidor.fechas.mes, "SEP") == 0 ||
        strcmp(competidor.fechas.mes, "OCT") == 0 || strcmp(competidor.fechas.mes, "NOV") == 0 || strcmp(competidor.fechas.mes, "DIC") == 0)) {
        error=1;
        printf("Mes invalido \n"); }
    if(competidor.edad>110 ||competidor.edad<=0){
        error=1;
        printf("Edad invalida \n");
    }
    if(competidor.tiempo<=0){
        error=1;
        printf("Tiempo invalido \n");
    }
    if (competidor.fechas.dia<=0 || competidor.fechas.dia>31){
        error=1;
        printf("Dia invalido \n");
    }
    if (competidor.activo==0){
        error=1; }
    return error;
    }

void pedir_datos_competidor(struct datacomp *nuevo){
    printf("Ingrese numero de orden: ");
    scanf("%d",&nuevo->orden);

    printf("Ingrese numero de corredor: ");
    scanf("%d", &nuevo->corredor);

    printf("Ingrese el dia: ");
    scanf("%d", &nuevo->fechas.dia);

    printf("Ingrese el mes: ");
    scanf("%s", &nuevo->fechas.mes);

    for (int i = 0; i < 3; i++) {
        if(nuevo->fechas.mes[i]>='a'&& nuevo->fechas.mes[i] <= 'z'){
            nuevo->fechas.mes[i]=nuevo->fechas.mes[i]-32;}
        }
    nuevo->fechas.mes[3] = '\0';

    printf("Ingrese el año: ");
    scanf("%d", &nuevo->fechas.ano);

    printf("Ingrese la edad: ");
    scanf("%d", &nuevo->edad);

    printf("Ingrese el pais: ");
    scanf("%s", nuevo->pais);

    for (int i = 0; i < 3; i++) {
        if(nuevo->pais[i]>='a'&& nuevo->pais[i] <= 'z'){
            nuevo->pais[i]=nuevo->pais[i]-32;}
        }
    nuevo->pais[3] = '\0';

    printf("Ingrese el tiempo: ");
    scanf("%f", &nuevo->tiempo);

    nuevo->activo = 1;
    return;
}

int obtener_ultimo_orden(FILE *archivoBIN) {
    struct datacomp temporal;
    fseek(archivoBIN,0,SEEK_SET);
    while (!feof(archivoBIN)){
        fread(&temporal, sizeof(struct datacomp), 1, archivoBIN);
    }
    return temporal.orden;
}

int checkeo_num_corredor(struct datacomp corredor, FILE *archivo){
    struct datacomp temporal;
    int flag=0;
    fseek(archivo,0,SEEK_SET);
    while (!feof(archivo)&&flag==0){
        fread(&temporal, sizeof(struct datacomp), 1, archivo);
        if (temporal.corredor==corredor.corredor){
            flag=1;
            printf("Ya existe un corredor con ese numero\n");
        }
    }
    return flag;
}

void nuevo_competidor(){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO, "rb+");

    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return;
    }
    int flag=1;

    struct datacomp nuevo;
    struct datacomp competidor_vacio = {0};
    struct datacomp test;

    while(flag==1){ //pido que se ingresen los datos
        pedir_datos_competidor(&nuevo);
        flag = checkeo_num_corredor(nuevo, archivoTexto) || check_validez(nuevo);
        if(flag==1){
            printf("Vuelva a ingresar los datos por favor \n");
        }
    }

    int ultimo_orden=obtener_ultimo_orden(archivoTexto);

    for (int i = ultimo_orden+1; i < nuevo.orden; i++) {//escribo los ceros necesarios
        fwrite(&competidor_vacio, sizeof(struct datacomp), 1, archivoTexto);
    }

    fseek(archivoTexto,(nuevo.orden-1)*sizeof(struct datacomp),SEEK_SET); //seteo el puntero en la direccion correcta
    fread(&test,sizeof(struct datacomp),1,archivoTexto); //leo lo que hay en ese renglon

    if(test.orden==competidor_vacio.orden || nuevo.orden>ultimo_orden ){ //me fijo si en el renglon que lei habian ceros o si el nuevo orden superaba al ultimo orden
        fseek(archivoTexto,(nuevo.orden-1)*sizeof(struct datacomp),SEEK_SET);
        fwrite(&nuevo,sizeof(struct datacomp),1,archivoTexto); //escribo el nuevo competidor
        printf("Competidor registrado \n");
    }
    else{
        int sobreescribir;
        printf("Ya existe un corredor con ese numero de orden,(1 para sobreescribir, 0 para cancelar) \n");//bucle para sobreescribir competidor
        scanf("%d",&sobreescribir);
        if(sobreescribir==1){
            fseek(archivoTexto,(nuevo.orden-1)*sizeof(struct datacomp),SEEK_SET);
            fwrite(&nuevo,sizeof(struct datacomp),1,archivoTexto); //escribo el nuevo competidor
            printf("Competidor registrado \n");
        }
    }
    fclose(archivoTexto);
    return;
}

int buscar_orden(int orden_deseado){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO,"rb");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return 0;
    }
    struct datacomp temporal;
    int flag=0;
    fseek(archivoTexto,0,SEEK_SET);
    while (!feof(archivoTexto)&&flag==0){
        fread(&temporal, sizeof(struct datacomp), 1, archivoTexto);
        if (temporal.orden==orden_deseado){//sale del loopp cuando encuentra un match
            flag=1;
        }
    }
    fclose(archivoTexto);
    if(flag==0){
        return 0;
    }
    return temporal.orden;
}

int buscar_corredor(int corredor_deseado){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO,"rb");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return 0;
    }
    struct datacomp temporal;
    int flag=0;
    fseek(archivoTexto,0,SEEK_SET);
    while (!feof(archivoTexto)&&flag==0){
        fread(&temporal, sizeof(struct datacomp), 1, archivoTexto);
        if (temporal.corredor==corredor_deseado){//sale del loopp cuando encuentra un match
            flag=1;
        }
    }
    fclose(archivoTexto);
    if(flag==0){
        return 0;
    }
    return temporal.orden;//me devuelve el numero de orden del corredor encontrado
}

int buscar(){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO,"rb");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return 0;
    }
    struct datacomp corredor_encontrado;
    int menu=0;
    while(menu!=1 && menu!=2){
        printf("Como desea buscar el competidor?\n 1-Numero de orden \n 2-Numero de corredor \n");
        scanf("%d",&menu);
        if(menu!=1 && menu!=2){
            printf("Opcion no valida \n");
        }
    }

    if(menu==1){//loop para buscar por numero de orden
        int orden=0;
        while(orden<=0){
            printf("Que numero de orden desea buscar? \n");
            scanf("%d",&orden);
            if(orden<=0){
                printf("Numero de orden no valido  \n");
            }
        }
        orden=buscar_orden(orden);
        if(orden==0){
            printf("Competidor no encontrado \n");
            fclose(archivoTexto);
            return 0;
        }
        fseek(archivoTexto,(orden-1)*sizeof(struct datacomp),SEEK_SET);//coloco eel cursor en la posicion indicada
        fread(&corredor_encontrado, sizeof(struct datacomp), 1, archivoTexto);//leo el contenido
    }

    if (menu==2){//loop para buscar por numero de corredor
        int corredor=0;
        while(corredor<=0){
            printf("Que numero de corredor desea buscar? \n");
            scanf("%d",&corredor);
            if(corredor<=0){
                printf("Numero de corredor no valido \n");
            }
        }
        corredor=buscar_corredor(corredor);
        if(corredor==0){
            printf("Competidor no encontrado \n");
            fclose(archivoTexto);
            return 0;
        }
        fseek(archivoTexto,(corredor-1)*sizeof(struct datacomp),SEEK_SET);//coloco eel cursor en la posicion indicada
        fread(&corredor_encontrado, sizeof(struct datacomp), 1, archivoTexto);//leo el contenido
    }
    //imprimo el corredor encontrado
    printf("Orden\tCorredor\tDia\tMes\tAño\tEdad\tPais\tTiempo\t\tActivo\n");
    printf("%d\t%d\t\t%d\t%s\t%d\t%d\t%s\t%.6f\t%d \n",
               corredor_encontrado.orden,
               corredor_encontrado.corredor,
               corredor_encontrado.fechas.dia,
               corredor_encontrado.fechas.mes,
               corredor_encontrado.fechas.ano,
               corredor_encontrado.edad,
               corredor_encontrado.pais,
               corredor_encontrado.tiempo,
               corredor_encontrado.activo);
    fclose(archivoTexto);
    return corredor_encontrado.orden;
}
void modificar_tiempo(){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO,"rb+");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return ;
    }

    struct datacomp competidor_mod;

    printf("MODIFICAR TIEMPO DEL COMPETIDOR \n");
    //busco el competidor
    int orden_mod=0;
    while(orden_mod==0){
        orden_mod=buscar();
        if(orden_mod==0){
            printf("Vuelva a buscar el competidor \n");
        }
    }
    float nuevo_tiempo=-1;
    while (nuevo_tiempo<0){
        printf("Ingrese nuevo tiempo \n");
        scanf("%f",&nuevo_tiempo);
        if(nuevo_tiempo<0){
            printf("Tiempo invalido \n");
        }
    }
    //modifico el tiempo
    fseek(archivoTexto,(orden_mod-1)*sizeof(struct datacomp),SEEK_SET);
    fread(&competidor_mod, sizeof(struct datacomp), 1, archivoTexto);
    competidor_mod.tiempo=nuevo_tiempo;
    fseek(archivoTexto,(orden_mod-1)*sizeof(struct datacomp),SEEK_SET);
    fwrite(&competidor_mod,sizeof(struct datacomp),1,archivoTexto);

    printf("Tiempo modificado con exito \n");
    fclose(archivoTexto);
    return;
}
void baja_logica(){
    FILE *archivoTexto = fopen(ARCHIVO_COMP_BINARIO,"rb+");
    if (archivoTexto == NULL) {
        printf("Error al abrir el archivo");
        return ;
    }

    struct datacomp competidor_mod;

    printf("DAR DE BAJA COMPETIDOR \n");

    int orden_mod=0;
    while(orden_mod==0){
        orden_mod=buscar();
        if(orden_mod==0){
            printf("Vuelva a buscar el competidor \n");
        }
    }

    int seguro;
    printf("Esta seguro de que quiere darlo de baja?\n 1-confirmar \n 0-cancelar\n");
    scanf("%d",&seguro);

    if (seguro==1){
        fseek(archivoTexto,(orden_mod-1)*sizeof(struct datacomp),SEEK_SET);
        fread(&competidor_mod, sizeof(struct datacomp), 1, archivoTexto);
        competidor_mod.activo=0;
        fseek(archivoTexto,(orden_mod-1)*sizeof(struct datacomp),SEEK_SET);
        fwrite(&competidor_mod,sizeof(struct datacomp),1,archivoTexto);

        printf("Competidor dado de baja con exito \n");}
    else{
        printf("Baja cancelada \n");
    }
    fclose(archivoTexto);
    return;
}
void bin_a_txt(const char nombre_archivo_txt[30],const char nombre_archivo_bin[30]){//funcion que traduce un archivo binario a uno txt
    FILE *archivo_txt=fopen(nombre_archivo_txt,"w+");
    FILE *archivo_bin=fopen(nombre_archivo_bin,"rb");
    fseek(archivo_bin,0,SEEK_SET);
    fseek(archivo_txt,0,SEEK_SET);

    struct datacomp competidor;
    while (fread(&competidor, sizeof(struct datacomp), 1, archivo_bin)==1){
        if (competidor.orden!=0){
        fprintf(archivo_txt,"%d;%d;%d;%s;%d;%d;%s;%.6f;%d\n",
               competidor.orden,
               competidor.corredor,
               competidor.fechas.dia,
               competidor.fechas.mes,
               competidor.fechas.ano,
               competidor.edad,
               competidor.pais,
               competidor.tiempo,
               competidor.activo);
        }
        else{
            fprintf(archivo_txt,"0;0;0;0;0;0;0;0;0\n");
        }
    }
    printf("DATOS GUARDADOS CON EXITO \n");
    fclose(archivo_bin);
    fclose(archivo_txt);
    return;
}

void bin_a_txt_bajas(const char nombre_archivo_txt[30],const char nombre_archivo_bin[30]){//lo mismo que antes pero en modo agregar
    FILE *archivo_txt=fopen(nombre_archivo_txt,"a");
    FILE *archivo_bin=fopen(nombre_archivo_bin,"rb");
    fseek(archivo_bin,0,SEEK_SET);
    fseek(archivo_txt,0,SEEK_SET);

    struct datacomp competidor;
    while (fread(&competidor, sizeof(struct datacomp), 1, archivo_bin)==1){
        if (competidor.orden!=0){
        fprintf(archivo_txt,"%d;%d;%d;%s;%d;%d;%s;%.6f;%d\n",
               competidor.orden,
               competidor.corredor,
               competidor.fechas.dia,
               competidor.fechas.mes,
               competidor.fechas.ano,
               competidor.edad,
               competidor.pais,
               competidor.tiempo,
               competidor.activo);
        }
        else{
            fprintf(archivo_txt,"0;0;0;0;0;0;0;0;0\n");
        }
    }
    printf("DATOS GUARDADOS CON EXITO \n");
    fclose(archivo_bin);
    fclose(archivo_txt);
    return;
}
void baja_fisica() {
    FILE *archivoOriginal = fopen(ARCHIVO_COMP_BINARIO, "rb+");
    if (archivoOriginal == NULL) {
        printf("Error al abrir el archivo original\n");
        return;
    }

    // Obtener fecha actual para el nombre del archivo
    time_t t = time(NULL);
    struct tm fechaActual = *localtime(&t);
    char nombreArchivoBajas[30];
    snprintf(nombreArchivoBajas, sizeof(nombreArchivoBajas), "competidores_bajas_%02d-%02d-%04d.xyz"
             ,fechaActual.tm_mday, fechaActual.tm_mon + 1, fechaActual.tm_year + 1900);

    FILE *archivoBajas = fopen(nombreArchivoBajas, "wb");
    if (archivoBajas == NULL) {
        printf("Error al crear el archivo de bajas\n");
        fclose(archivoOriginal);
        return;
    }

    struct datacomp competidor;
    struct datacomp competidorVacio = {0};

    fseek(archivoOriginal, 0, SEEK_SET);
    while (fread(&competidor, sizeof(struct datacomp), 1, archivoOriginal)==1){
        if (competidor.activo == 0 && competidor.orden!=0) {  // Verificar si el competidor está inactivo
            fwrite(&competidor,sizeof(struct datacomp),1,archivoBajas);//Escribir el competidor en el archivo de las bajas
            // Marcar competidor como vacío en el archivo original
            fseek(archivoOriginal, (competidor.orden-1)*sizeof(struct datacomp), SEEK_SET); // seteo el cursor
            fwrite(&competidorVacio, sizeof(struct datacomp), 1, archivoOriginal);//lleno de ceros
            fseek(archivoOriginal, +sizeof(struct datacomp), SEEK_CUR);// vuelvo a setear el cursor
        }
    }
    fclose(archivoOriginal);
    fclose(archivoBajas);
    printf("Archivo de bajas generado \n");
    bin_a_txt_bajas("ult_competidores_bajas.txt",nombreArchivoBajas);
}
void mostrar_menu() {
    int opcion = 0;
    while (opcion !=12) {
        printf("\n--- MENU PRINCIPAL ---\n");
        printf("1. Listar archivo TXT\n");
        printf("2. Crear nuevo archivo binario\n");
        printf("3. Migrar datos del TXT a archivo binario\n");
        printf("4. Listar contenido del archivo binario\n");
        printf("5. Registrar nuevos competidores (Alta)\n");
        printf("6. Buscar competidor\n");
        printf("7. Modificar tiempo de competidor\n");
        printf("8. Dar de baja lógica a competidor\n");
        printf("9. Baja física de competidores inactivos\n");
        printf("10. Listar archivo XYZ de bajas\n");
        printf("11. Migrar datos del archivo binario al archivo TXT \n");
        printf("12. Salir\n");
        printf("Seleccione una opción: ");
        scanf("%d", &opcion);

        switch(opcion) {
            case 1:
                listar_txt(ARCHIVO_COMP_TXT);
                break;
            case 2:
                creo_archivo_Bin();
                break;
            case 3:
                migrar_datos();
                break;
            case 4:
                listar_dat();
                break;
            case 5:
                nuevo_competidor();
                break;
            case 6:
                buscar();
                break;
            case 7:
                modificar_tiempo();
                break;
            case 8:
                baja_logica();
                break;
            case 9:
                baja_fisica();
                break;
            case 10:
                listar_txt("ult_competidores_bajas.txt");
                break;
            case 11:
                bin_a_txt(ARCHIVO_COMP_TXT,ARCHIVO_COMP_BINARIO);
                break;
            case 12:
                printf("Saliendo del programa.\n");
                break;
            default:
                printf("Opción inválida. Intente de nuevo.\n");
        }
    }
}



#endif // MI_LIBRERIA_H_INCLUDED
