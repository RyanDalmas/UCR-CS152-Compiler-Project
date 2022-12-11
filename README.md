# Project-Code-Generator-No_Klizzy
This is the final implementation of **Kliz-C** compiler
## Instructions
1. Build The Compiler: 
 - To build the compiler, use ```make``` or ```make parser```
2. Generate mil code:
 - Send a file contents stream into the parser. ie:
```
cat ./testcase/test_arrays.klz | ./parser
```
3. To run the generated code, use:
```
./mil_run ./klizzy.mil
```
> You may have to add execution priveleges to mil_run file using ```chmod +x ./mil_run```
> If parser fails on line 1, try ```make clean```, then rebuild the compiler. (See bullet 1)

***Note: This compiler uses flex_old.***
## Video Demo Link
https://www.youtube.com/watch?v=gO_Gaoisz74&feature=youtu.be
## Language Features

The main features of our language include :
* Arrays
* Loops
* If-Else Statements
* Functions

### Examples 
#### Arrays
This is an example where we create an array named **arrayTest** and use array assignment statements using a scalar variable, expression, and array access. Then we are printing out the values of the array from index 0-3.
```
i func main() {
    i [4] arrayTest;

    arrayTest[0] = 2;
    arrayTest[1] = 4 + 6;
    arrayTest[2] = 6 + 2 * 4 / 2;
    arrayTest[3] = arrayTest[0];

    out(arrayTest[0]);
    out(arrayTest[1]);
    out(arrayTest[2]);
    out(arrayTest[3]);
};
```
### Loops
In this example, we declare a variable ``sum`` and assign 0 to in. Then, in a while-loop statement we called ```until```, we add 1 to sum until it is 50, then it exits the loop and outputs **sum**.
```
i func main() {
    i sum = 0;

    out(sum);

    until(sum < 50)
    {
        sum = sum + 1;
    };

    out(sum);
};
```
### If-then-else Statement
In this example, we make a ```sum``` variale and set it to 25. In the first if-else statement, we test if the if condition ```if(sum < 50)``` passes, and it should output 1. Then in the second if-statement, we test if the else works, ```ow```, then it should output 4. 
```
i func main() {
    i sum = 25;

    if(sum < 50){
        out(1);
    }
    ow{
        out(2);
    };

    if(sum > 50){
        out(3);
    }
    ow{
        out(4);
    };
};
```

### Functions
This is the fibonacci implementation of our Kliz-C language.
```
i func fibonacci(i num){
    i t1 = 0;
    i t2 = 1;
    i nextTerm = t1 + t2;

    out(t1);
    out(t2);

    i count = 3;
    num = num + 1;
    until(count < num) {
        out(nextTerm);
        t1 = t2;
        t2 = nextTerm;
        nextTerm = t1 + t2;
        count = count + 1;
    };

    send 1;
};

i func main() {
    i ret = fibonacci(9);
};
```

This is the bubble-sort implementation of Kilz-C Language
```
i func main() {
    i [10] array;

    array[0] = 100;
    array[1] = 100000;
    array[2] = 10000;
    array[3] = 1;
    array[4] = 10;
    array[5] = 1000;
    array[6] = 1000000;
    array[7] = 1000000000;
    array[8] = 100000000;
    array[9] = 10000000;

    out(array[0]);
    out(array[1]);
    out(array[2]);
    out(array[3]);
    out(array[4]);    
    out(array[5]);
    out(array[6]);
    out(array[7]);
    out(array[8]);
    out(array[9]);

    i swapped = 1;

    until(swapped == 1) {
        swapped = 0;
        i va = 0;
        until(va < 9) {
            if (array[va] > array[va + 1]) {
                i swap = array[va];
                array[va] = array[va + 1];
                array[va + 1] = swap;
                swapped = 1;
            };
            va = va + 1;
        };
    };

    out(array[0]);
    out(array[1]);
    out(array[2]);
    out(array[3]);
    out(array[4]);    
    out(array[5]);
    out(array[6]);
    out(array[7]);
    out(array[8]);
    out(array[9]);
};
```
