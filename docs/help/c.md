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