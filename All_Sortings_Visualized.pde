/**

ALGORITMOS DE ORDENAMIENTO VISUALIZADOS

Por David Gamaliel Arcos Bravo
Fecha: 29 de Febrero del 2020

Se muestran las visualizaciones de los siguientes algoritmos de ordenamiento (con sus respectivos indices y complejidades):
0.- BUBBLE SORT          O(n²)
1.- SELECTION SORT       O(n²)
2.- INSERTION SORT       O(n²)
3.- HEAP SORT            O(nlogn)
4.- MERGE SORT           O(nlogn)
5.- QUICK SORT           O(nlogn)
6.- RADIX SORT           O(nm)
7.- BOGO SORT // extra   O(∞)

Cada uno de ellos es ejecutado en su hilo correspondiente, para seleccionar uno individualmente se modifican los parametros mostrados abajo

Para el sonido, es necesario instalar la libreria Sound de Processing

**/

// Importamos la libreria Sound para los efectos de sonido
import processing.sound.*;

// PARAMETROS

int ancho = 1000;                             // Int que representa el ancho de la pantalla
int largo = 1000;                             // Int que representa el largo de la pantalla
int cant = 100;                               // Cantidad de elementos
int range = ancho/cant;                       // Ancho de cada elemento en a pantalla
IntList arr = new IntList(cant);              // Arreglo donde guardaremos los elementos
IntList cambio = new IntList(cant);           // Arreglo para definir el color de cada elemento
IntList heap = new IntList(cant+1);           // Arreglo extra para el heap de HeapSort
ArrayList<IntList> rad = new ArrayList(10);   // Matriz que guarda los elementos segun sus digitos en Radix Sort
boolean haya = true;                          // Boolque me indica si los elementos ya estan ordenados en Radix Sort
int pot = 1;                                  // Int que me da el digito en el que voy a checar en Radix Sort

// PARAMETROS DE SONIDO

// Preferentemente evitar modificarlos
SinOsc[] sineWaves;                           // Arreglo de ondas
float[] sineFreq;                             // Arreglo de frecuencias
int numSines = 10;                            // Numero de ondas
float yoffset, frequency, detune;             // Variables para definir el sonido
int inc = 0;                                  // Variable para modificar la frecuencia de cada onda

// MAS PARAMETROS

boolean heapo=false;                          // Bool que representa si se esta ejecutando HeapSort
boolean no_ejecutando=true;                   // Bool que representa si cualquier sorting esta siendo ejecutado
String s = new String("");                    // String para guardar que sorting esta siendo ejecutado
int comparaciones = 0;                        // Int que guarda cuantas comparaciones a hecho el respectivo sorting
int cambios = 0;                              // Int que guarda cuantos cambios a hecho el respectivo sorting
int accesos = 0;                              // Int que guarda cuantas accesos al arreglo a hecho el respectivo sorting
boolean insertando = false;                   // Bool que dice si se estan insertando elementos en el heap
int ejecutando_hilo = 0;                      // Int que guarda que hilo esta siendo ejecutado, y por lo tanto que sorting
int del = 2;                                  // Int que guarda el tiempo en milisegundos de la ejecucion de los algoritmos
int del2 = 10;                                // Int que guarda el tiempo en milisegundos de la impresion del arreglo ordenado
int delshow = 3000;                           // Int que guarda el tiempo en milisegundos de la impresion del arreglo ordenado final

/** MODIFICACIONES

     Este programa esta diseñado para funcionar con los parametros previamente establecidos, pero pueden ser modificados por quien lo use segun sus necesidades
     Si quiere omitir el Bogo Sort, cambiar su valor en el switch casea un valor mayor al presentado
     Si se quiere modificar el numero de elementos, modifique la variable cant
     Si quiere empezar por cierto algoritmo de ordenacion, modifique la variable ejecutando_hilo con el valor del indice del 
     algoritmo que quiera ejecutar (Se muestran los indices en la parte superior)
     Si quiere modificar la velocidad de la presentacion, modifique la variable del para la ejecucion,
     la variable del2 para la presentacion del arreglo ordenado
     o la variable delshow para el tiempo de pantalla congelada entre un algoritmo y otro
     Preferentemente no modificar las variables del sonido
     Si se modifica el tamaño de la pantalla, modificar tambien los parametros ancho y largo
     Para omitir el sonido, modifique la variable numSines a 0
     
**/

void setup(){
  // Aqui inicializamos el sonido que vamos a usar
  sineWaves = new SinOsc[numSines];
  sineFreq = new float[numSines]; 
  for (int i = 0; i < numSines; i++) {
    float sineVolume = (1.0 / numSines) / (i + 1);
    sineWaves[i] = new SinOsc(this);
    sineWaves[i].play();
    sineWaves[i].amp(sineVolume);
  }

  // Aqui inicializamos el arreglo y los colores de los elementos
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  
  // La ejecucion de los algoritmos esta pensada para una pantalla de 1000x1000, sin embargo puede cambiarse a pantalla completa, pero la visualizacion se verá afectada
  size(1000,1000); // Si se modifica el tamaño de la pantalla, modificar tambien los parametros ancho y largo
  //fullScreen();
}

void draw(){
  // Inicializamos los colores iniciales
  background(0);
  fill(255);
  stroke(0);
  // Aqui se imprimen los rectangulos que representan a los elementos
  for(int i=0;i<cant;i++){
    // Si el cambio en i es 0, ese elemento no esta siendo usado, si es 1, esta siendo usado y se marca rojo, si es 2, esta totalmente ordenado y se marca verde
    if(heapo){   // El caso del HeapSort se imprime de forma especial, pues se asigna un color por cada nivel del arbol
      if(i+1<=inde&&cambio.get(i)==0){
        int pot=1,conta=0;
        for(pot=1;pot<i;pot*=2){conta++;}
        int r = 255; if(conta%3==0)r-=(conta/3)*100;
        int g = 255; if(conta%3==1)g-=(conta/3)*100;
        int b = 255; if(conta%3==2)b-=(conta/3)*100;
        fill(r,g,b);
        rect(i*range,height-heap.get(i+1)*range,range,heap.get(i+1)*range);
      }else{
        if(cambio.get(i)==1)fill(255,0,0); else if(cambio.get(i)==2)fill(0,255,0); else fill(255);
        rect(i*range,height-arr.get(i)*range,range,arr.get(i)*range);
      }
    }else{
      if(cambio.get(i)==1)fill(255,0,0); else if(cambio.get(i)==2)fill(0,255,0); else fill(255);
      rect(i*range,height-arr.get(i)*range,range,arr.get(i)*range);
    }
  }
  
  // Aqui imprimimos en texto en la pantalla el sorting en ejecucion, el numero de elementos, y los cambios, comparaciones y accesos hechos
  textSize(50);
  fill(255);
  textAlign(CENTER,CENTER);
  text(s,width/2,40);
  textSize(30);
  //text("Elementos: "+cant+"    Comparaciones: "+comparaciones+"    Cambios: "+cambios+"    Accesos: "+accesos,width/2,90); // Todo en una solo linea
  text("Elementos: "+cant+"    Comparaciones: "+comparaciones,width/2,90);
  text("Cambios: "+cambios+"    Accesos: "+accesos,width/2,140);
  
  // Aqui ejecutamos el hilo correspondiente al algoritmo siguiente, o ignoramos en caso de que haya uno en ejecucion actualmente
  // Cada sorting cambia dependiendo a la variable ejecutando_hilo
  if(no_ejecutando){
    switch(ejecutando_hilo){
      case 0:  no_ejecutando=true; 
        thread("bubble");
        ejecutando_hilo++;
        break;
      case 1:  no_ejecutando=true; 
        thread("selection");
        ejecutando_hilo++;
        break;
      case 2:  no_ejecutando=true; 
        thread("insertion");
        ejecutando_hilo++;
        break;
      case 3:  no_ejecutando=true;
        thread("heap");
        ejecutando_hilo++;
        break;
      case 4:  no_ejecutando=true; 
        thread("merge");
        ejecutando_hilo++;
        break;
      case 5:  no_ejecutando=true;
        thread("quick");
        ejecutando_hilo++;
        break;
      case 6:  no_ejecutando=true;
        thread("radix");
        ejecutando_hilo++;
        break;
      case 7:  no_ejecutando=true; 
        thread("bogo");
        ejecutando_hilo++;
        break;
      default: ejecutando_hilo = 0;
        break;
    }
  }
  
  // Aqui modificamos  la frecuencia dependiendo de la variable inc, que se modifica dentro de cada sorting en tiempo de ejecucion
  yoffset = 0.1;
  frequency = pow(1000, yoffset) + inc;
  detune = -0.2;

  // Aqui se modifica la frecuencia de cada onda
  for (int i = 0; i < numSines; i++) { 
    sineFreq[i] = frequency * (i + 1 * detune);
    sineWaves[i].freq(sineFreq[i]);
  }
  
}

// Funcion que nos devuelve true si el arr ya esta ordenado, y false si no
boolean sorted(){
  accesos+=2*(cant-1);
  for(int i=0;i<cant-1;i++){
    if(arr.get(i)>arr.get(i+1))return false;
  }
  return true;
}

// Funcion que intercambia dos elementos en arr
void swap(int i,int j){
  accesos+=4;
  cambios+=2;
   int aux=arr.get(i);
   arr.set(i,arr.get(j));
   arr.set(j,aux);
}

// Funcion que intercambia dos elementos en el arreglo heap
void swap_heap(int i,int j){
  accesos+=4;
  cambios+=2;
   int aux=heap.get(i);
   heap.set(i,heap.get(j));
   heap.set(j,aux);
}

// Funcion que desordena aleatoriamente arr
void shuff(){
  for(int veces=0;veces<cant*7;veces++){
    int a=(int)random(0,cant); 
    int b=(int)random(0,cant); 
    swap(a,b);
  }
}

/** NOTAS

   En todos los algoritmos presentados, el proceso es el siguiente
   1.- Se inicializan todas las variables en 0
   2.- A la String s se le asigna el nombre del algoritmo en ejecucion
   3.- Se inicializa el arreglo de elementos y de colores
   4.- Se usa la funcion shuff para desordenar el arreglo de elementos
   6.- Se lleva a cabo el algoritmo de ordenamiento correspondiente
   7.- Se imprime el arreglo ordenado en color verde
   8.- Finaliza la ejecucion del algoritmo
   
   Cada algoritmo tiene su respectivo proceso y explicacion
   En los algoritmos O(nlogn), los metodos usados son recursivos, y todos cuentan con una funcion extra, a excepcion de HeapSort que tiene 2
   IMPORTANTE - El uso de las variables comparaciones, accesos, cambios, no_ejecutando, heapo, inc, asi como el arreglo cambios, y el uso del delay, entre otros
   no son necesarios para la ejecucion del algoritmo, son auxiliares para la visualizacion del mismo, y pueden ser omitidos si se esta realizando en otros lenguajes
   Las partes marcadas con VISUALIZACION pueden ser removidas si esta no se desea
   
**/


// ++++++++++++++++++++++++++++++++++++++++++++++++ BUBBLE SORT ++++++++++++++++++++++++++++++++++++++++++++++++

void bubble(){
  no_ejecutando=false;
  s = "BUBBLE SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Bubble Sort
    La idea de Bubble Sort es la siguiente
    Por cada elemento en i y en i+1, si el elemento en i es mayor al elemento en i+1, hago swap en ellos
    Esto garantiza que al final de cada ciclo, el elemento mas grande quede al final del arreglo
    Asi que dentro de 2 cicos for podemos ir añadiendo ese elemento hasta el final y finalmente dejarlo ordenado
    EL primer for se ejecuta n veces, mientras que le segundo va reduciendo en q por cada iteracion, debido a que
    el ultimo elemento ya esta 'ordenado', aunque esto puede omitirse y dejar que se ejecute n veces, no afectara el resultado
  **/
  for(int i=0;i<cant;i++){
     for(int j=1;j<cant-i;j++){
       comparaciones++;
       accesos+=2;
       cambio.set(j,1);
       cambio.set(j-1,1);
       if(arr.get(j-1)>arr.get(j)){
         cambios++;
         accesos+=2;
         swap(j-1,j);
         delay(del);
         inc = arr.get(j-1)*range*3;
       }
       delay(del);
       cambio.set(j,0);
       cambio.set(j-1,0);
     }
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ SELECTION SORT ++++++++++++++++++++++++++++++++++++++++++++++++

void selection(){
  s = "SELECTION SORT";
  no_ejecutando=false;
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Selection Sort
    La idea de Selection Sort es la siguiente
    Se divide el arreglo en una parte ordenada y una parte no ordenada
    Se toma el argumento mas grande del arreglo no ordenado mediante una busqueda lineal, y se intercambia con el ultimo elemento del arreglo no ordenado
    AL hacerlo ese elemento ahora forma parte del arreglo ordenado, y el espacio de busqueda se reduce en 1
    Se utilizan 2 ciclos for, uno que se ejecuta n veces, y otro que se ejecuta n veces 
    y por cada iteracion se reduce en 1
  **/
  for(int i=0;i<cant;i++){
    inc=0;
    accesos++;
    int mayor = arr.get(0);
    int index = 0;
    cambio.set(0,1);
    cambio.set(cant-i-1,1);
     for(int j=1;j<cant-i;j++){
       inc+=100;
       comparaciones++;
       accesos++;
       if(arr.get(j)>mayor){
         cambio.set(j,1);
         cambio.set(index,0);
         accesos++;
         cambios++;
         mayor=arr.get(j);
         index=j;
         delay(del);
       }
       delay(del);
     }
     swap(index,cant-i-1);
     delay(del);
     cambio.set(index,0);
     cambio.set(cant-i-1,0);
     delay(del);
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ INSERTION SORT ++++++++++++++++++++++++++++++++++++++++++++++++

void insertion(){
  no_ejecutando=false;
  s = "INSERTION SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Insertion Sort
    La idea de Insertion Sort es la siguiente
    Se divide el arreglo en una parte ordenada y una parte no ordenada
    Se toma el primer argumento del arreglo no ordenado y se procede a insertarlo en el arreglo ordenado
    Para insertarlo, se pregunta si el elemento que tome es menor que el elemento del arreglo ordenado
    Si lo es, aplica swap en ellos y se procede a comparar con el siguiente elemento del arreglo
    Si no, entonces esa es su posicion en el arreglo ordenado, y se acaba ese ciclo
    AL hacerlo ese elemento ahora forma parte del arreglo ordenado, y el espacio de busqueda se reduce en 1
    Se utilizan 2 ciclos for, uno que se ejecuta n veces, y otro que se ejecuta n veces 
    y por cada iteracion se reduce en 1
  **/
  for(int i=0;i<cant;i++){
    int index = i;
    cambio.set(index,1);
    inc=0;
     for(int j=i-1;j>=0;j--){
       inc+=100;
       comparaciones++;
       cambio.set(index,1);
       cambio.set(j,1);
       delay(del);
       accesos+=2;
       if(arr.get(index)<arr.get(j)){
         cambio.set(index,0);
         cambios+=3;
         swap(index,j);
         cambio.set(j,0);
         index=j;
         delay(del);
       }else {
         cambio.set(j,0);
         cambio.set(index,0);
         break;
       }
       delay(del);
     }
     delay(del);
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ HEAP SORT ++++++++++++++++++++++++++++++++++++++++++++++++


int inde=0;   // Esta variable guarda el indice actual del arreglo heap, que guarda el heap usado para ordenar

// Funcion que inserta los elementos en el heap
void insertar(int val){
  insertando = true;
  accesos++;
  // Se incrementa el tamaño de arbol en 1, donde irá el elemento a insertar
  inde++;
  inc = inde*100;
  cambios++;
  // Seañade el nuevo elemento
  heap.set(inde,val);
  // Se usa una variable auxiliar que tiene el tamaño del heap
  int hijo=inde;
  delay(del);
  // Mientras que no se llegue al nodo raiz, el cual ya no puede subir mas, se ejecuta el ciclo
  while(hijo>1){
    accesos+=2;
    comparaciones++;
    // Si el nodo hijo es menor que el padre, se intercambian y se repirte el proceso, sino, el proceso finaliza
    int padre = hijo/2;
    cambio.set(hijo-1,1);
    cambio.set(padre-1,1);
    delay(del);
    if(heap.get(hijo)>heap.get(padre)){
       swap_heap(hijo,padre);
       swap(hijo-1,padre-1);
       accesos-=4;
       cambios-=2;
       delay(del);
       cambio.set(hijo-1,0);
       cambio.set(padre-1,0);
       delay(del);
       hijo = padre;
       inc = hijo*100;
    }else{
      insertando = false;
      cambio.set(hijo-1,0);
      cambio.set(padre-1,0);
      delay(del);
      return; 
    }
  }
  insertando = false;
}

// Funcion que elimina el elemento mas grande del heap
void eliminar(){
  // Se intercambian el nodo raiz con el ultimo elemento
  cambio.set(inde-1,1);
  cambio.set(0,1);
  delay(del);
  swap_heap(1,inde);
  accesos+=2;
  cambios++;
  // Se añade al final arreglo el elemento mas grande que queremos
  swap(inde-1,0);
  delay(del);
  cambio.set(inde-1,0);
  cambio.set(0,0);
  // Se decrementa el tamaño del heap en uno, que es el elemento eliminado
  inde--;
  // Mientras el nodo padre este dentro de los parametros del heap, se ejecuta el ciclo
  int padre=1;
  delay(del);
  while(padre<=inde){
    inc = padre*100;
    // Se determinan los dos hijos del nodo, y se toma al padre como referencia del elemento mas grande
    int chido = padre;
    int h1 = padre*2;
    int h2 = padre*2+1;
    // Si el hijo 1 es mayor que el mayor, se toma el hijo 1 como mayor
    if(h1<=inde&&heap.get(h1)>heap.get(chido)){ 
      accesos+=2;
      comparaciones++;
      chido=h1;
      delay(del);
      inc = h1*100;
    }
    // Si el hijo 2 es mayor que el mayor, se toma el hijo 2 como mayor
    if(h2<=inde&&heap.get(h2)>heap.get(chido)){
      accesos+=2;
      comparaciones++;
      chido=h2;
      delay(del);
      inc = h2*100;
    }
    cambio.set(padre-1,1);
    cambio.set(chido-1,1);
    delay(del);
    // Si el padre sigue siendo el mayor, se termina la ejecucion
    if(chido==padre){
      delay(del);
      cambio.set(padre-1,0);
      return;
    }
    // Si no, se intercambia el padre con el hijo mayor y se sigue la ejecucion con el
    swap_heap(padre,chido);
    swap(chido-1,padre-1);
    accesos-=4;
    cambios-=2;
    delay(del);
    cambio.set(padre-1,0);
    cambio.set(chido-1,0);
    delay(del);
    padre=chido;
    delay(del);
  }
}

void heap(){
  heapo=true;
  no_ejecutando=false;
  s = "HEAP SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Heap Sort
    La idea de Heap Sort es la siguiente
    Se tiene un arbol binario completo, es decir que todos sus niveles estan llenos, y cargados hacia un lado, en este caso a la izquierda
    NOTA: Los nodos hijo de un nodo i son el elemento i*2 e i*2+1, por lo tanto el padre de un nodo i es el elemento i/2
    Los indices de un heap empiezan en 1, por lo que el indice 0 es descartado
    Queremos que el elemento raiz del heap sea el elemento mas grande de todos los elementos, y lo logramos con el metodo de insercion siguiente
    Se insertan todos los elementos en el heap de la siguiente forma 
      Se añade el elemento hasta el final del heap, y se procede a subirlo de nivel
      Si el padre de ese elemento es menor que el, entonces hacen swap y se aplica el mismo metodo hasta llegar a la raiz
      Si no, esa es su posicion correspondiente
    Esto nos asegura que el nodo raiz del arbol sera el elemento mas grande posible
    Asi, para ordenarlo solo tenemos que sacar ese elemento uno por uno, y cada vez que saquemos un elemento actuaizarlo con el mas grande de los que quedan, para lo que sera la funcion eliminar
      Se intercambia el elemento raiz y el ultimo elemento del heap, y eliminamos el ultimo elemento del heap. Esto lo guardamos en el arreglo que queremos ordenar
      Despues, para no alterar la propiedad del heap, tenemos que 'bajar' el elemento raiz para 'subir' los elementos mayores
      Se pregunta cual de los 3 elemento es el mas grande (ente el padre o los 2 hijos)
      Si es alguno de los hijos, este sera intercambiado con el padre, y se procedera a hacer ese mismo procedimiento con ese elemento hasta llegar al ultimo nivel del arbol
      Si no, se acaba la ejecucion de la funcion
    Asi al eliminar todos los elementos, se obtendra un arreglo ordenado
  **/
  
  // Primero se insertan todos los elementos en el heap con a funcion insertar
  for(int i=0;i<cant;i++){
    accesos++;
    cambio.set(i,1);
    insertar(arr.get(i));
    delay(del);
    cambio.set(i,0);
    delay(del);
  }
  
  // Despues se elimina uno por uno el elemento mas grande del heap, y por ende de forma ordenada
  for(int i=0;i<cant;i++){
    eliminar();
    delay(del);
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
  heapo=false;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ MERGE SORT ++++++++++++++++++++++++++++++++++++++++++++++++

IntList merge_arr(int l, int r,IntList cosa, int lreal, int rreal){
  // NOTA: Las variables lreal y rreal son auxiliares para la impresion por pantalla, y pueden ser omitidas
  // Caso base, si l == r, el tamaño es 1 y ya esta ordenado, por lo que se regresa el mismo arreglo
  if(l==r)return cosa;
  int med = (l+r)/2;              // Int que representa el indice medio del arreglo
  int medreal = (lreal+rreal)/2;  // Int que representa el indice medio del arreglo real
  IntList a = new IntList();      // Arreglo de la primera mitad
  IntList b = new IntList();      // Arreglo de la segunda mitad
  accesos+=r-l;
  // Se llenan ambos arreglos con sus respectivas mitades
  for(int i=l;i<=med;i++){ a.append(cosa.get(i)); }
  for(int i=med+1;i<=r;i++){ b.append(cosa.get(i)); }
  // Se aplica recursivamente el algoritmo merge a ambos arreglos
  a = merge_arr(0,a.size()-1,a,lreal,medreal);
  b = merge_arr(0,b.size()-1,b,medreal+1,rreal);
  // Se mezclan ambos arreglos
  for(int i=l,uno=0,dos=0;i<=r;i++){   // Se inicializan las variables uno y dos adicionales en el for
    // Las variables auxiliares uno y dos representan el indice del arreglo a y b, respectivamente, al que se esta haciendo referencia
    if(uno==a.size()){          // Si la variabe auxiliar uno es igual al tamaño del arreglo a, este arreglo ya fue tomado totalmente, y se toma
      accesos+=2;               // el siguiente elemento del arreglo b
      cambios++;
      cosa.set(i,b.get(dos++));
    }else if(dos==b.size()){    // Si la variabe auxiliar dos es igual al tamaño del arreglo b, este arreglo ya fue tomado totalmente, y se toma
      accesos+=2;               // el siguiente elemento del arreglo a
      cambios++;    
      cosa.set(i,a.get(uno++));
    }else if(a.get(uno)<b.get(dos)){   // Si ninguno de los dos arreglos ha sido tomado totalmente, se toma el menor de ambos
      accesos+=4;                      // y se incrementa el indice auxiliar de el respectivo arreglo
      cambios++;
      comparaciones++;
      cosa.set(i,a.get(uno++));
    }else{
      accesos+=4;
      cambios++;
      comparaciones++;
      cosa.set(i,b.get(dos++));
    }
    
    // BLOQUE DE VISUALIZACION
    arr.set(lreal + i,cosa.get(i));
    inc = arr.get(lreal+i)*range*2;
    delay(del);
    cambio.set(lreal + i,1);
    delay(del);
    cambio.set(lreal + i,0);
  }
  // Se regresa el arreglo mezclado ya ordenado
  return cosa;
}

void merge(){
  no_ejecutando=false;  
  s = "MERGE SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Merge Sort
    La idea de Merge Sort es la siguiente
    Se divide el arreglo en 2 partes, que seran ordenadas y despues mezcladas
    Para ordenar estas partes, se aplica a su vez el algoritmo MergeSort, y asi se aplica hasta que se llegue 
    a arreglos de tamaño 1. Al contener 1 solo elemento, el arreglo ya esta ordenado.
    Este metodo se aplica recursivamente
    Primero se manda un arreglo, se separa, se aplica recursivamente ese algoritmo a ambos, y cuando esten ordenados, se mezclan
    Se toma un arreglo auxiliar, y se toma el elemento menor de cada arreglo ordenado, que posteriormente sera borrado
    Al final, se tiene el arreglo final ordenado, y se regresa el arreglo ordenado
  **/
  /// NOTA: En esta implementacion, se usan dos variables extra para la impresion en pantalla, las cuales pueden ser omitidas
  arr = merge_arr(0,cant-1,arr,0,cant-1);
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ QUICK SORT ++++++++++++++++++++++++++++++++++++++++++++++++

IntList quick_arr(int l, int r,IntList cosa, int lreal, int rreal){
  // NOTA: Las variables lreal y rreal son auxiliares para la impresion por pantalla, y pueden ser omitidas
  // El caso base, si el arreglo es de tamaño 1 o de tamaño 0, estara ordenado, y se regresa ese mismo arreglo
  if(l==r||cosa.size()==0||cosa.size()==1)return cosa;
  IntList a = new IntList(0);       // Arreglo de la primera mitad
  IntList b = new IntList(0);       // Arreglo de la segunda mitad
  int pivot = cosa.get(0);          // Int que representa el elemento pivote, escogido arbitrariamente
  accesos++;
  
  // Se añade cada elemento a su respectivo arreglo
  for(int i=1;i<cosa.size();i++){
    // Si es menor al pivote, se añade al arreglo a, si no, al arreglo b
    if(cosa.get(i)<pivot){
      accesos++;
      comparaciones++;
      a.append(cosa.get(i));
    }else{
      accesos++;
      comparaciones++;
      b.append(cosa.get(i));
    }
  }
  
  // BLOQUE DE VISUALIZACION
  int med=a.size();
  cambio.set(lreal+med,1);
  arr.set(lreal+med,pivot);
  a.append(pivot);
  for(int i=lreal,uno=0,dos=0;i<=rreal;i++){
    cambio.set(lreal+med,1);
    if(uno<a.size()){
      arr.set(i,a.get(uno++));
    }else{
      arr.set(i,b.get(dos++));
    }
    inc = arr.get(i)*range*2;
    delay(del);
    cambio.set(lreal + i,1);
    delay(del);
    cambio.set(lreal + i,0);
  }
  a.pop();
  cambio.set(lreal+med,0);
  
  // Se aplica recursivamente el algoritmo quick a ambos arreglos
  a = quick_arr(0,a.size()-1,a,lreal,lreal+a.size()-1);
  b = quick_arr(0,b.size()-1,b,lreal+a.size()+1,rreal);
 
 // Se concatenan el arreglo a con el pivote y el arreglo b en ese orden
  a.append(pivot);
  a.append(b);
  // Seregresa el arreglo ordenado
  return a;
}

void quick(){
  no_ejecutando=false;
  s = "QUICK SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Quick Sort
    La idea de Quick Sort es la siguiente
    Se toma arbitrariamente un elemeno pivote, y se separan los elementos en dos arreglos, con elementos mayores al pivote, y con mayores al pivote
    Este metodo se aplica recursivamente
    Primero se manda un arreglo, se separa conforme al pivote, se aplica recursivamente ese algoritmo a ambos, y cuando esten ordenados, se concatenan junto con el pivote
    Los elementos mayores al pivote se agregan a un arreglo, y los menores a otro, se apica recursivamente el metodo a ambos, y cuando estan ordenados, simplemente se concatenan
    y se tiene el arreglo totalmente ordenado
    Al final, se tiene el arreglo final ordenado, y se regresa el arreglo ordenado
  **/
  /// NOTA: En esta implementacion, se usan dos variables extra para la impresion en pantalla, las cuales pueden ser omitidas
  IntList aux = quick_arr(0,cant-1,arr,0,cant-1);
  arr= aux;
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ RADIX SORT ++++++++++++++++++++++++++++++++++++++++++++++++

void radix(){
  no_ejecutando=false;
  s = "RADIX SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  for(int i=0;i<10;i++){
    rad.add(new IntList());
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Radix Sort
    La idea de Radix Sort es la siguiente
    Ordenamos los numeros segun su digito, y los tomamos segun las potencias de 10
    Tenemos una arreglo de arreglos de 10 casillas, y agregamos cada elemento segun el digito que tomemos
    Por cada iteracion, la potencia se multiplica por 10 para checar el siguiente digito en potencia de 10 de cada numero
    Al final no se ocupan comparaciones ya que todos los digitos quedaran ordenados por todos los digitos que tienen
  **/
  pot = 1;
  while(haya){
    haya = false;
    inc = 0;
    for(int i = 0;i < cant;i++){
      accesos++;
      int aux = (arr.get(i)/pot)%10;
      if(aux!=0)haya = true;
      rad.get(aux).append(arr.get(i));
      delay(del);
      inc+=100*(aux+1);
    }
    int index = 0;
    inc = 0;
    for(int i=0;i<10;i++){
       for(int j=0;j<rad.get(i).size();j++){
          inc = arr.get(j)*range*3;
          arr.set(index++, rad.get(i).get(j));
          cambio.set(index,1);
          delay(del);
          cambio.set(index,0);
          delay(del);
          cambios++;
       }
       delay(del);
    }
    for(int i=0;i<10;i++){
      rad.set(i,new IntList());
      delay(del);
    }
    pot*=10;
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0; 
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}


// ++++++++++++++++++++++++++++++++++++++++++++++++ BOGO SORT ++++++++++++++++++++++++++++++++++++++++++++++++

// Algoritmo de ordenamiento extra :D

void bogo(){
  no_ejecutando=false;
  s = "BOGO SORT";
  for(int i=0;i<cant;i++){
     arr.set(i,i+1);
     cambio.set(i,0);
  }
  shuff();
  comparaciones=0;
  cambios=0;
  accesos=0;
  
  /** Bogo Sort
    La idea de Bogo Sort es la siguiente
    Se toman arbitrariamente dos indices y se intercambian
    Eso es todo :D
    Si esta ordenado, acabaste, si no, lo haces hasta que jale
  **/
  while(!sorted()){
    comparaciones += cant;
    int a=(int)random(0,cant); 
    int b=(int)random(0,cant); 
    swap(a,b);
    
    // BLOQUE DE VISUALIZACION
    cambio.set(a,1);
    cambio.set(b,1);
    int cosaa = 40;
    inc = a*range*2;
    delay(cosaa);
    inc = b*range*5;
    delay(cosaa);
    inc = a*range*5;
    delay(cosaa);
    inc = b*range*2;
    delay(cosaa);
    cambios+=3;
    cambio.set(a,0);
    cambio.set(b,0);
  }
  
  // BLOQUE DE VISUALIZACION
  inc=0;
  for(int j=0;j<cant;j++){
      cambio.set(j,2);
      inc = arr.get(j)*range*3;
      delay(del2);
  }
  inc = 0;
  delay(delshow);
  no_ejecutando=true;
}

// Es todo, si llegaste hasta aqui, que va, espero que te sirva :D
// Suerte
