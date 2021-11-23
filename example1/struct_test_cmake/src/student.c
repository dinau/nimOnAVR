// Made by audin 2021/11 http://mpu.seesaa.net
#include "student.h"
#include "xprintf.h"

void show_and_modify_by_c_lang(Student *std){
    xputs("\n");
    xprintf("\n ======= Received the object pointer of std from Nim at C language function =======");
    xprintf("\n    std.Age = %d"                , std->age);
    xprintf("\n    std.cstrinName  = %s"        , std->cstringName);
    xprintf("\n    std.arrayName   = %s"        , std->arrayName);
    xputs("\n");
    xprintf("\n    &std.Age            = 0x%08x", &std->age);
    xprintf("\n    &std.cstringNname   = 0x%08x", &std->cstringName);
    xprintf("\n    &std.arrayName      = 0x%08x", &std->arrayName);
    xprintf("\n    &std.ctringNname[0] = 0x%08x", &std->cstringName[0]);
    xprintf("\n    &std.arrayName[0]   = 0x%08x", &std->arrayName[0]);
    xputs("\n");
    xputs("\n    Now changing the object data as follows,");
    xputs("\n      std->age += 50;");
    xputs("\n      std->cstringName[0]='0';");
    xputs("\n      std->cstringName[1]='1';");
    xputs("\n      std->cstringName[2]='\\0';");
    xputs("\n");
    xputs("\n      std->arrayName[0]  ='1';");
    xputs("\n      std->arrayName[1]  ='2';");
    xputs("\n      std->arrayName[2]  ='3';");
    xputs("\n      std->arrayName[3]  ='4';");
    xputs("\n      std->arrayName[4]  ='5';");
    xputs("\n      std->arrayName[5]  ='\\0';");
    xputs("\n");
    xprintf("\n ============ in C language function end =======\n");
    std->age += 50;
    std->cstringName[0]='0';
    std->cstringName[1]='1';
    std->cstringName[2]='\0';
    std->arrayName[0]  ='1';
    std->arrayName[1]  ='2';
    std->arrayName[2]  ='3';
    std->arrayName[3]  ='4';
    std->arrayName[4]  ='5';
    std->arrayName[5]  ='\0';
}

#if defined(ENABLE_MAIN) // for C language test only
char str[] = "xyzab";
Student std ;
int main(void){
    std.age = 25;
    std.cstringName = str;
    std.arrayName[0]='A';
    std.arrayName[1]='B';
    std.arrayName[2]='\0';
    show_and_modify_by_c_lang(&std);

    xprintf("\n    std.Age = %d", std.age);
    xprintf("\n    std.cstrinName  = %s",   std.cstringName);
    xprintf("\n    std.arrayName   = %s\n", std.arrayName);

    return 0;
}
#endif

