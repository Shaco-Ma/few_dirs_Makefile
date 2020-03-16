#include <iostream>
#include "a.h"
#include "b.h"
#include "c.h"
#include "test.h"

using namespace std;

int main(void)
{
    cout << a() << endl;
    cout << b() << endl;
    cout << c() << endl;
	test();
    cout << "Fuck C Plus Plus!" << endl;
}
