struct person[
	string name;
	int age;
]

/*int fun(string sss){
	sss = "a";
	return 0;
}*/

int change(int a){
	a = 10;
	int b;
	b = 100;
	float c = 12.03;
	c = a + 9.9;
	c = 10.9 + a;
	print(c);
	return a;
}

int main(){
	struct person a;
	struct person b;
	b.age = 9;
	print(b.age + 10);
	print(10/3);
	a.name = "100";
	b.name = "200";
	int bbb = 0;
	change(bbb);

}


