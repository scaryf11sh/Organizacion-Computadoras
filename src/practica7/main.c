#include <inttypes.h>  // For PRId64 macro
#include <math.h>
#include <stddef.h>
#include <stdint.h>  // For int64_t
#include <stdio.h>
#include <stdlib.h>

int myatoi(const char*);
char* myitoa(int);

int main(void) {
  char* string = "Hola\0";
  char* string2 = "12345\0";
  char* string3 = "-342j\0";

  printf("%s a atoi -> %d\n", string, myatoi(string));
  printf("%s a atoi -> %d\n", string2, myatoi(string2));
  printf("%s a atoi -> %d\n", string3, myatoi(string3));

  int n = -12;
  char* itoastr = myitoa(n);
  printf("%d a itoa -> %s\n", n, itoastr);
  char* itoastr2 = myitoa(123);
  printf("%d a itoa -> %s\n", 123, itoastr2);
  char* itoastr3 = myitoa(-34287);
  printf("%d a itoa -> %s\n", -34287, itoastr3);
  free(itoastr);
}

int myatoi(const char* string) {
  size_t strlen = 0;

  while (string[strlen] != '\0') strlen++;

  int nums = 0;
  for (int i = 0; i < strlen; i++)
    if (string[i] >= 48 && string[i] <= 57) nums++;

  if (nums == 0) return 0;

  int result = 0;
  unsigned int sign = 1;
  for (int i = 0; i < strlen; i++) {
    if (string[i] == 45)
      sign = (sign == 1) ? -1 : 1;
    else if (string[i] <= 57 && string[i] >= 48)
      result += (string[i] - '0') * pow(10, --nums);
  }

  result *= sign;
  return result;
}

char* myitoa(int num) {
  if (num == 0) {
    char* string = (char*)calloc(2, sizeof(char));
    string[0] = '0';
    string[1] = '\0';
    return string;
  }

  unsigned int copy = abs(num);
  unsigned int digits = 0;
  while (copy > 0) {
    digits++;
    copy /= 10;
  }

  int sign = (num > 0) - (num < 0);
  size_t strlen = digits + ((sign == -1) ? 1 : 0);
  char* string = (char*)calloc(strlen + 1, sizeof(char));
  string[strlen] = '\0';

  if (sign == -1) num = -num;

  while (num > 0) {
    string[--strlen] = (num % 10) + '0';
    num /= 10;
  }

  if (sign == -1) string[0] = '-';

  return string;
}
