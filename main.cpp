#include <iostream>
#include "aa.h"
#include "a.h"
#include "b.h"
#include "c.h"
#include "test.h"

using namespace std;

int main(void)
{
	print_cur();
    cout << a() << endl;
    cout << b() << endl;
    cout << c() << endl;
	test();
    cout << "Fuck C Plus Plus!" << endl;
}
