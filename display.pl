split([],_N,[],[]):-!.
split(L,0,[],L):-!.
split([H|T], N, [H|LS1],LS2):- N1 is N-1, split(T,N1,LS1,LS2).

slice([],_I,_F,[]):-!.
slice(L,1,F,X):- !,split(L,F,X,_L).
slice([_H|T],I,F,X):- I2 is I-1, F2 is F-1, slice(T,I2,F2,X).

/*secuencia decreciente para cada combinacion*/
numero_decreciente("NNNNNNN","NNNNNNN",true):- !.
numero_decreciente("YYYYYYN","YYYYNYY",true):- !.
numero_decreciente("YYYYYYN","YNYYNYY",true):- !.
numero_decreciente("NYYNNNN","YYYYYYN",true):- !.
numero_decreciente("YYNYYNY","NYYNNNN",true):- !.
numero_decreciente("YYYYNNY","YYNYYNY",true):- !.
numero_decreciente("NYYNNYY","YYYYNNY",true):- !.
numero_decreciente("YNYYNYY","NYYNNYY",true):- !.
numero_decreciente("YNYYYYY","YNYYNYY",true):- !.
numero_decreciente("YYYNNNN","YNYYYYY",true):- !.
numero_decreciente("YYYYYYY","YYYNNNN",true):- !.
numero_decreciente("YYYYNYY","YYYYYYY",true):- !.

/*realiza las combinaciones leds quemados  de 2 secuencias de BCD */
combinaciones_aux(L,[H|[]],[X]):- append(L,H,X),!.
combinaciones_aux(L,[H|T],X):- combinaciones_aux(L,T,X1), append(L,H,X2), append([X2],X1,X),!.

combinaciones([89|[]],L,[[89]],[L]):-!.
combinaciones(L,[89|[]],[L],[[89]]):-!.
combinaciones([78|[]],[78|[]],[[89],[78]],[[89],[78]]):-!.
combinaciones([89|T1],[H|T2],C1,C2):- combinaciones(T1,T2,X1,Y2),combinaciones_aux([89],X1,C1),combinaciones_aux([H],Y2,C2),!.
combinaciones([H|T1],[89|T2],C1,C2):- combinaciones(T1,T2,X1,Y2), combinaciones_aux([H],X1,C1),combinaciones_aux([89],Y2,C2),!.
combinaciones([78|T1],[78|T2],C1,C2):- combinaciones(T1,T2,X1,Y1), combinaciones_aux([89],X1,X2),combinaciones_aux([78],X1,X3),
								combinaciones_aux([89],Y1,Y2),combinaciones_aux([78],Y1,Y3),append(X3,X2,C1),append(Y3,Y2,C2),!.
								
								
								
/* recibe 2 secuencias de BCD realiza las combinaciones con los led quemados y verifica 
   si se puede formar un cero en el en el display anterior*/
cero(S,[H|[]],true):- S == H,!.
cero(S,[_H|T],true):- S == H,!.
cero(S,[_H|T],X):-cero(S,T,X),!.
cero(S1,S2,X):- combinaciones(S1,S2,C1,_C2), cero("YYYYYYN",C1,X),!.

/* recibe 2 secuencias de BCD realiza las combinaciones con los led quemados y verifica 
   si no se puede formar un cero en el en el display anterior*/
no_cero(S1,S2,false):- cero(S1,S2,X1),X1,!.
no_cero(S1,S2,true):-!.

/*recibe 2 secuencias de BCD realiza las combinaciones con los led quemados y verifica 
   si ambos display pueden formar un numero igual*/
igual(N1,N2,X):- combinaciones(N1,N2,C1,_C2),combinaciones(N2,N2,C3,C4),igual_aux(C1,C3,C3,X).
igual_aux([H1|[]],[H2|[]],L,true):- H1==H2,!.
igual_aux([H1|_T1],[H2|[]],L,true):- H1==H2,!.
igual_aux([_H1|T1],[_H2|[]],L,X):- igual_aux(T1,L,L,X),!.
igual_aux([H1|_T1],[H2|_T2],L,true):- H1==H2,!.
igual_aux([H1|T1],[_H2|T2],L,X):- igual_aux([H1|T1],T2,L,X),!.

/*recibe una secuencia de 21 caracteres y retorna minitos, decenas de segundos y segundos*/
numero([H|_], MIN,DSEG,SEG):- slice(H, 1, 7, MIN), slice(H, 8, 14, DSEG), slice(H, 15, 21, SEG),!.

/*recibe 2 secuencias BCD y busca una secuencia valida decreciente*/
buscar_secuencia(N1,N2,X):- combinaciones(N1,N2,C1,C2),combinaciones(N2,N2,C3,C4),buscar_secuencia_aux(C1,C3,C3,X).
buscar_secuencia_aux([H1|[]],[H2|[]],L,X):- numero_decreciente(H1,H2,X),!.
buscar_secuencia_aux([H1|_T1],[H2|[]],L,X):- numero_decreciente(H1,H2,X),!.
buscar_secuencia_aux([_H1|T1],[_H2|[]],L,X):- buscar_secuencia_aux(T1,L,L,X),!.
buscar_secuencia_aux([H1|_T1],[H2|_T2],L,X):- numero_decreciente(H1,H2,X),!.
buscar_secuencia_aux([H1|T1],[_H2|T2],L,X):- buscar_secuencia_aux([H1|T1],T2,L,X),!.

/*recibe minutos, decenas de segundos , unidades segundos ,minutos , decenas de segundos , unidades segundos
 y verifica que el contador sea decreciete*/
validarTiempo(M,DS,S,M1,DS1,S1,X):- igual(M,M1,B1),B1,igual(DS,DS1,B2),B2, no_cero(S,S1,O),O, buscar_secuencia(S,S1,X),! .
validarTiempo(M,DS,S,M1,DS1,S1,X):- igual(M,M1,B1),B1,no_cero(DS,DS1,O),O, buscar_secuencia(DS,DS1,X1),X1,buscar_secuencia(S,S1,X),! .
validarTiempo(M,DS,S,M1,DS1,S1,X):- cero(DS,DS1,O1),O1, cero(S,S1,O2),O2,buscar_secuencia(M,M1,X1),X1,
									buscar_secuencia(DS,DS1,X2),X2,buscar_secuencia(S,S1,X),! .

/*recibe una lista de secuencias para BCD y busca una secuencia decreciente*/
decremento([HA],true):-  length(HA,X), X == 21,! .
decremento([HA,H],X):- numero([HA],MIN,DSEG,SEG) , numero([H],MIN1,DSEG1,SEG1),validarTiempo(MIN,DSEG,SEG,MIN1,DSEG1,SEG1,X),!.
decremento([HA,H|T],X):- numero([HA],MIN,DSEG,SEG),numero([H],MIN1,DSEG1,SEG1),validarTiempo(MIN,DSEG,SEG,MIN1,DSEG1,SEG1,X1),X1,decremento([H|T],X),!.





