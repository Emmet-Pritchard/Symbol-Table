
/* CS270 
 *
 * Author: Your name here
 * Date:   2/12/2020
 */

#include "struct.h"
#include<stdio.h>
#include<stdlib.h>

/********** FUNCTION DEFINITIONS **********************************************/

void readStudentAndEnroll(Student **slot){
    Student *john = malloc(sizeof(Student));
    scanf("%s", john->firstName);
    scanf("%f", &(john->qualityPoints));
    scanf("%d", &(john->numCredits));
    *slot = john;
}

void displayStudent(Student s){
    float GPA = s.qualityPoints / s.numCredits;
    printf("%s, %.2f\n", s.firstName, GPA);
}
