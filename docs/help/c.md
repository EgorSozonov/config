### Global constant

1. Declare it as extern in a header file

`extern String empty;`

2. Define it in the corresponding .c file

`String empty = { .length = 0 };`

3. Use it everywhere!

## Array of function pointers


	int sum(int a, int b);
	int subtract(int a, int b);
	
	int (*p[4]) (int x, int y);
	
	int main(void) {
	       int result;
	       int i, j, op;
	
	       p[0] = sum;
	       p[1] = subtract;
	  
		   result = (*p[op]) (i, j);
	}

 Pointer to an array 
 
     int (* ptr)[5] = NULL;

Array of pointers

    int* ptr[5];

Pointer to array of pointers

    int* (*pArr)[5] = &arr;

### Return an array from function

```c
// Function returning Array Char with length = HEIGHT
char (*foo(int width))[LENGTH] {
    // dynamically allocate memory for a widthxHEIGHT array of char
    char (*newArr)[LENGTH] = malloc(sizeof *newArr * width);
  
    // initialize array contents here
    return newArr;
}
```

The syntax  reads as ("the spiral rule")

```c
       foo                          // foo
       foo(int width)               // is a function
                                    // taking an int param
      *foo(int width)               // returning a pointer
     (*foo(int width))[LENGTH]      // to a HEIGHT-element array
char (*foo(int width))[LENGTH]      // of char
```

## Structs

### Mutually recursive structs

    typedef struct LanguageDefinition LanguageDefinition;
    typedef struct Lexer Lexer;
    struct LanguageDefinition {...};
    struct Lexer {...};

### Struct with private fields (opaque)

In .h file:

    typedef struct StringMap StringMap;

In .c file:

    struct StringMap {
        Arr(ValueList*) dict;
        ...
    };


### Null-safety
    `nonnull (arg-index, ...)`

The `nonnull` attribute specifies that some function parameters should be non-null pointers. For instance, the declaration:

          extern void *
          myMemcpy (void *dest, const void *src, size_t len)
                  __attribute__((nonnull (1, 2)));
     

causes the compiler to check that, in calls to `myMemcpy`, arguments dest and src are non-null. If the compiler determines that a null pointer is passed in an argument slot marked as non-null, and the -Wnonnull option is enabled, a warning is issued. The compiler may also choose to make optimizations based on the knowledge that certain function arguments will not be null.

If no argument index list is given to the `nonnull` attribute, all pointer arguments are marked as non-null. To illustrate, the following declaration is equivalent to the previous example:

          extern void *
          my_memcpy (void *dest, const void *src, size_t len)
                  __attribute__((nonnull));

### Errors instead of just warnings

Error on undeclared function

     -Werror=implicit-function-declaration

## Memory

posix_memalign

mmap


## Function pointers

### Call any function with any arguments!

    void** vtable = ...;
    ((void(*)())vtable[5])(arg1, arg2, arg3);

## Varargs


```
int addNums(...){
    int result = 0;
    va_list args;
    va_start(args);
 
    int count = va_arg(args, int);
    for (int i = 0; i < count; ++i) {
        result += va_arg(args, int);
    }
 
    va_end(args);
    return result;
}
```
    
    
## Wrapping Sepples code   
    
Suppose that I have a C++ class named AAA, defined in files aaa.h, aaa.cpp, and that the class AAA has a method named `sayHi(const char *name)`, that I want to enable for C code.
The C++ code of class AAA - Pure C++, I don't modify it:

aaa.h

    #ifndef AAA_H
    #define AAA_H

    class AAA {
        public:
            AAA();
            void sayHi(const char *name);
    };

    #endif

aaa.cpp

    #include <iostream>
    #include "aaa.h"

    AAA::AAA() {
    }

    void AAA::sayHi(const char *name) {
        std::cout << "Hi " << name << std::endl;
    }

Compiling this class as regularly done for C++. This code "does not know" that it is going to be used by C code. Using the command:

    g++ -fpic -shared aaa.cpp -o libaaa.so

Now, also in C++, creating a C connector:

Defining it in files aaa_c_connector.h, aaa_c_connector.cpp. This connector is going to define a C function, named `AAA_sayHi(const char *name)`, that will use an instance of AAA and will call its method:

aaa_c_connector.h

    #ifndef AAA_C_CONNECTOR_H 
    #define AAA_C_CONNECTOR_H 

    #ifdef __cplusplus
    extern "C" {
    #endif
 
    void AAA_sayHi(const char *name);

    #ifdef __cplusplus
    }
    #endif

    #endif

aaa_c_connector.cpp

    #include <cstdlib>

    #include "aaa_c_connector.h"
    #include "aaa.h"

    #ifdef __cplusplus
    extern "C" {
    #endif

    // Inside this "extern C" block, I can implement functions in C++, which will externally 
    //   appear as C functions (which means that the function IDs will be their names, unlike
    //   the regular C++ behavior, which allows defining multiple functions with the same name
    //   (overloading) and hence uses function signature hashing to enforce unique IDs),


    static AAA *AAA_instance = NULL;

    void lazyAAA() {
        if (AAA_instance == NULL) {
            AAA_instance = new AAA();
        }
    }

    void AAA_sayHi(const char *name) {
        lazyAAA();
        AAA_instance->sayHi(name);
    }

    #ifdef __cplusplus
    }
    #endif

Compiling it, again, using a regular C++ compilation command:

    g++ -fpic -shared aaa_c_connector.cpp -L. -laaa -o libaaa_c_connector.so

Now I have a shared library (libaaa_c_connector.so), that implements the C function `AAA_sayHi(const char *name)`. I can now create a C main file and compile it all together:

main.c

    #include "aaa_c_connector.h"

    int main() {
        AAA_sayHi("David");
        AAA_sayHi("James");

        return 0;
    }

Compiling it using a C compilation command:

    gcc main.c -L. -laaa_c_connector -o c_aaa

I will need to set LD_LIBRARY_PATH to contain $PWD, and if I run the executable ./c_aaa, I will get the output I expect:

Hi David
Hi James

EDIT:

On some Linux distributions, -laaa and -lstdc++ may also be required for the last compilation command.    
