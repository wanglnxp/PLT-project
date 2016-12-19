#include <stdio.h>
#include <stdlib.h>

int print_number(int a){
	return a;
}

/*struct s {
	int x;
	int y;
};

char* input() {
	int initial_size = INIT_SIZE;
	char* str = malloc(initial_size);
	int index = 0;
	char tmp = '0';
	while((tmp = getchar() )!= '\n') {
		if(index >= initial_size - 1) {
			str = realloc(str, initial_size *= 2);
		}
		str[index++] = tmp;
	}
	str[index] = '\0';
	return str;
}*/
