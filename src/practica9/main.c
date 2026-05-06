#include <stdio.h>

extern int maximo(int *, int);
extern int minimo(int *, int);
extern int sumatoria(int *, int);

int main(void) {
  int size = 0;
  int valid = 0;

  do {
    printf("Ingresa el Numero de elementos del arreglo (1-5): ");
    scanf("%d", &size);

    valid = (size > 0 && size <= 5) ? 1 : 0;
  } while (!valid);

  int array[size];

  for (int i = 0; i < size; i++) {
    printf("Ingresa el numero para el elemento %d: ", i);
    scanf("%d", &array[i]);
  }

  printf("El elemento mayor es: %d\n", maximo(array, size));
  printf("El elemento menor es: %d\n", minimo(array, size));
  printf("La sumatoria del arreglo es: %d\n", sumatoria(array, size));

  return 0;
}
