struct person[
	string name;
	int age;
]

/*int fun(string sss){
	sss = "a";
	return 0;
}*/

int change(int a){
	a = a+1;
	int b;
	b = 100;
	return a;
}

int main(){
	struct person a;
	struct person b;
	a.name = "100";
	b.name = "200";
	int bbb = 0;
	change(bbb);

}


