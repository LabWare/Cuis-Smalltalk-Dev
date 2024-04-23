# Cuis FFI Primer

Cuis has the ability to load dynamic libraries and call functions defined in them. The libraries must use the C calling convention.

  - [Define Library Class](#define-library-class)
  - [Opening and Closing Dynamic Libraries](#opening-and-closing-dynamic-libraries)
  - [Wrapping Library Functions](#wrapping-library-functions)
    - [Example C Function Wrapper Method](#example-c-function-wrapper-method)
  - [Argument Types](#argument-types)
    - [OLD Argument Types](#old-argument-types)
    - [Return Type](#return-type)
  - [Structures](#structures)

## Define Library Class

In order to use a library, make a subclass of ExternalLibrary and implement the moduleName class method. Libraries should be accessed via singletons as they can only be opened once. The common pattern in Cuis is to use class instance variable named 'default' to reference this.
```
!classDefinition: #MyLibrary category: #'MyPackage-MyCategory'!
ExternalLibrary subclass: #MyLibrary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MyPackage-MyCategory'!

!classDefinition: #MyLibrary category: #'MyPackage-MyCategory'!
MyLibrary class
	instanceVariableNames: 'default'!

!MyLibrary class methodsFor: 'MyPackage-MyCategory'!
moduleName
    "Return the name of the module for this library"
    (Smalltalk platformName = 'Win32')
        ifTrue:[^'mylib.dll'].
    (Smalltalk platformName = 'unix')
        ifTrue:[^'mylib.so'].
    (Smalltalk platformName = 'Mac OS')
        ifTrue:[^'mylib.dylib'].
    ^self error: 'Platform not supported'! !

!MyLibrary class methodsFor: 'MyPackage-MyCategory'!
default
    "Answer the library singleton"
    ^default ifNil:[default := super new]! !


!MyLibrary class methodsFor: 'MyPackage-MyCategory'!
new
    "Prevent multiple instances"
	^self error: 'use #default'! !
```

## Opening and Closing Dynamic Libraries

Dynamic libraries are typically opened lazily when a function is first called. To force a library to load, send `#forceLoading` to the library singleton.
```
MyLibrary default forceLoading.
```
NOTE: Cuis does not currently have a method in the FFI package to close a library. Edit: try: `Smalltalk unloadModule: <module name>`

## Wrapping Library Functions

In order to be able to call a function from a library, an instance method must be added to the library class. The method should contain:
- Method Selector - There is no direct connection between the method selector and the function name, but it is generally suggested to closely replicate the function name.
- Method Arguments - The names of the arguments do not matter other than they must be unique and begin with a lowercase letter
- (optional) Comment - Often the function's C declaration is provided in the comment along with the description of the function
- Function Declaration - Consists of angle brackets containing "cdecl:", the return type, the function name, argument types inside parenthesis
- Alternate Code - Code to run if the function fails. This is typically `^self externalCallFailed`

### Example C Function Wrapper Method

```
!ODBC3Library class methodsFor: 'ODBC3-primitives'!
sqlBindParameter: statementHandle
parameterNumber: parameterNumber
inputOutputType: inputOutputType
valueType: valueType
parameterType: parameterType
columnSize: columnSize
decimalDigits: decimalDigits
parameterValuePtr: parameterValuePtr
bufferLength: bufferLength
strLenOrIndPtr: strLenOrIndPtr

    "SQLRETURN SQLBindParameter(  
        SQLHSTMT        StatementHandle,  
        SQLUSMALLINT    ParameterNumber,  
        SQLSMALLINT     InputOutputType,  
        SQLSMALLINT     ValueType,  
        SQLSMALLINT     ParameterType,  
        SQLULEN         ColumnSize,  
        SQLSMALLINT     DecimalDigits,  
        SQLPOINTER      ParameterValuePtr,  
        SQLLEN          BufferLength,  
        SQLLEN *        StrLen_or_IndPtr);"

    <cdecl: int16 'SQLBindParameter' (SQLHSTMT uint16 int16 int16 int16 uint3264 int16 void* int3264 SQLInteger*)>
    ^self externalCallFailed! !
```  
This function "SQLBindParameter" takes ten parameters and answers a SQLRETURN. It is necessary to look at the header file(s) to determine the atomic datatypes being used. In this case, SQLRETURN turns out to be a 16-bit integer. The first and last arguments for this function are passed as structures. StatementHandle is using the structure SQLHSTMT, which is defined as a subclass of ExternalStructure. Similarly, StrLen_or_IndPtr is defined as a SQLInteger* structure. The asterisk indicates that a pointer to the structure should be sent.

### Argument Types

The previous function used a combination of built-in data types and structures. The following built-in data types can be used:

| Data Type  | Description (32-bit Image)          | Description (64-bit Image)          |
|:-----------|:------------------------------------|:------------------------------------|
|  bool      |  8-bit Boolean                      |  8-bit Boolean                      |
|  char      |  8-bit Character (Unsigned)         |  8-bit Character (Unsigned)         |
| schar      |  8-bit Character (Signed)           |  8-bit Character (Signed)           |
|  float     | 4-byte Single precision float       | 4-byte Single precision float       |
|  double    | 8-byte Double precision float       | 8-byte Double precision float       |
| uint8      |  8-bit Integer (Unsigned)           |  8-bit Integer (Unsigned)           |
|  int8      |  8-bit Integer (Signed)             |  8-bit Integer (Signed)             |
| uint16     | 16-bit Integer (Unsigned)           | 16-bit Integer (Unsigned)           |
|  int16     | 16-bit Integer (Signed)             | 16-bit Integer (Signed)             |
| uint32     | 32-bit Integer (Unsigned)           | 32-bit Integer (Unsigned)           |
|  int32     | 32-bit Integer (Signed)             | 32-bit Integer (Signed)             |
| uint64     | 64-bit Integer (Unsigned)           | 64-bit Integer (Unsigned)           |
|  int64     | 64-bit Integer (Signed)             | 64-bit Integer (Signed)             |
| uint3264   | 32-bit Integer (Unsigned)           | 64-bit Integer (Unsigned)           |
|  int3264   | 32-bit Integer (Signed)             | 64-bit Integer (Signed)             |

#### Deprecated Argument Types

The following argument types are considered deprecated. The newer, more explicit data types should be used instead.
- byte - Same as uint8
- sbyte - Same as int8
- ushort - Same as uint16
- short - Same as int16
- ulong - Same as uint32
- long - Same as int32
- ulonglong - Same as uint64
- longlong - Same as int64
- size_t - Same as uint3264

### Return Type

Any of the atomic argument types may be used as a return type. [TODO: Can structures or pointers to structures be used as a return type?]

## Structures

Structures used for FFI calls are derived from ExternalStructure.