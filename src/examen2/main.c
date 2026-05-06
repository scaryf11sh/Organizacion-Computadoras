#include <stdbool.h>
#include <stdio.h>

bool isPrime(int);

int main(void) {
  int num;
  printf("Ingrese un numero entero positivo mayor a 1: ");
  scanf("%d", &num);
  bool isprime = isPrime(num);
  printf("El numero %s es primo\n", (isprime) ? "si" : "no");

  return 0;
}

bool isPrime(int number) {
  if (number <= 1)
    return false;
  if (number % 2 == 0)
    return (number == 2) ? true : false;

  int cociente = number / 2;

  for (int i = --cociente; i >= 3; i -= 2)
    if (number % i == 0)
      return false;

  return true;
}
