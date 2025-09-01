/*
Turf!
Nos encargaron el diseño de una aplicación para modelar carreras de caballo en hipódromos (todo totalmente legal). A continuación dejamos los primeros requerimientos, sabiendo que nuestra intención es aplicar los conocimientos del paradigma lógico.
Punto 1: Pasos al costado (2 puntos)
Les jockeys son personas que montan el caballo en la carrera: tenemos a Valdivieso, que mide 155 cms y pesa 52 kilos, Leguisamo, que mide 161 cms y pesa 49 kilos, Lezcano, que mide 149 cms y pesa 50 kilos, Baratucci, que mide 153 cms y pesa 55 kilos, Falero, que mide 157 cms y pesa 52 kilos.

También tenemos a los caballos: Botafogo, Old Man, Enérgica, Mat Boy y Yatasto, entre otros. Cada caballo tiene sus preferencias:
a Botafogo le gusta que le jockey pese menos de 52 kilos o que sea Baratucci
a Old Man le gusta que le jockey sea alguna persona de muchas letras (más de 7), existe el predicado atom_length/2
a Enérgica le gustan todes les jockeys que no le gusten a Botafogo
a Mat Boy le gusta les jockeys que midan mas de 170 cms
a Yatasto no le gusta ningún jockey

También sabemos el Stud o la caballeriza al que representa cada jockey
Valdivieso y Falero son del stud El Tute
Lezcano representa a Las Hormigas
Y Baratucci y Leguisamo a El Charabón

Por otra parte, sabemos que Botafogo ganó el Gran Premio Nacional y el Gran Premio República, Old Man ganó el Gran Premio República y el Campeonato Palermo de Oro y Enérgica y Yatasto no ganaron ningún campeonato. Mat Boy ganó el Gran Premio Criadores.

Modelar estos hechos en la base de conocimientos e indicar en caso de ser necesario si algún concepto interviene a la hora de hacer dicho diseño justificando su decisión.


*/


jockey(valdivieso, 155, 52).
jockey(leguisamo, 161, 49).
jockey(lezcano, 149, 50).
jockey(baratucci, 153, 55).
jockey(falero, 157,52).

caballo(Caballo) :- distinct(Caballo, preferenciaCaballo(Caballo, _)).
caballo(yatasto).

preferenciaCaballo(botafogo, Jockey) :-
    jockey(Jockey, _, Peso), Peso < 52.
preferenciaCaballo(botafogo, baratucci).
preferenciaCaballo(oldMan, Jockey) :-
    jockey(Jockey, _, _) ,atom_length(Jockey, CantidadLetras), CantidadLetras > 7.
preferenciaCaballo(energica, Jockey) :- jockey(Jockey, _, _),
    not(preferenciaCaballo(botafogo, Jockey)).
preferenciaCaballo(matBoy, Jockey) :- jockey(Jockey, Altura, _), Altura > 170.

% yatasto no lo escribimos por principio de universo cerrado, entendiendo que si hacemos la consulta de preferenciaCaballo(yatasto, Jockey). esta dara false, pues es verdadero unicamente lo que esta en nuestra base de conocimiento.

stud(valdivieso, elTute).
stud(falero, elTute).
stud(lezcano, lasHormigas).
stud(baratucci, elCharabon).
stud(leguisamo, elCharabon).

premio(botafogo, granPremioNacional).
premio(botafogo, granPremioRepublica).
premio(oldMan, granPremioRepublica).
premio(oldMan, campeonatoPalermoDeOro).
premio(matBoy, granPremioCriadores).

%como energica y yatasto no ganaron ningun premio no lo ponemos en nuestra base de conocimiento y por principio de universo cerrado, al hacer la consulta premio(energica, Premio). dara False.


/*Punto 2: Para mí, para vos (2 puntos)
Queremos saber quiénes son los caballos que prefieren a más de un jockey. Ej: Botafogo, Old Man y Enérgica son caballos que cumplen esta condición según la base de conocimiento planteada. El predicado debe ser inversible.
*/

prefiereAMasDeUno(Caballo) :-
    preferenciaCaballo(Caballo, Jockey), preferenciaCaballo(Caballo, OtroJockey), Jockey \= OtroJockey.


/*Punto 3: No se llama Amor (2 puntos)
Queremos saber quiénes son los caballos que no prefieren a ningún jockey de una caballeriza. El predicado debe ser inversible. Ej: Botafogo aborrece a El Tute (porque no prefiere a Valdivieso ni a Falero), Old Man aborrece a Las Hormigas y Mat Boy aborrece a todos los studs, entre otros ejemplos.
*/

aborrece(Caballo, Stud) :-
    caballo(Caballo), stud(_, Stud), not((preferenciaCaballo(Caballo, Jockey), stud(Jockey, Stud))).

/*
Punto 4: Piolines (2 puntos)
Queremos saber quiénes son les jockeys "piolines", que son las personas preferidas por todos los caballos que ganaron un premio importante. El Gran Premio Nacional y el Gran Premio República son premios importantes.

Por ejemplo, Leguisamo y Baratucci son piolines, no así Lezcano que es preferida por Botafogo pero no por Old Man. El predicado debe ser inversible.
*/

premioImportante(granPremioNacional).
premioImportante(granPremioRepublica).

ganoPremioImportante(Caballo, Premio):- premioImportante(Premio), premio(Caballo, Premio).


piolin(Jockey) :-
    jockey(Jockey, _, _), 
    forall(ganoPremioImportante(Caballo, _), preferenciaCaballo(Caballo, Jockey)).



/*
Punto 5: El jugador (2 puntos)
Existen apuestas
a ganador por un caballo => gana si el caballo resulta ganador
a segundo por un caballo => gana si el caballo sale primero o segundo
exacta => apuesta por dos caballos, y gana si el primer caballo sale primero y el segundo caballo sale segundo
imperfecta => apuesta por dos caballos y gana si los caballos terminan primero y segundo sin importar el orden

Queremos saber, dada una apuesta y el resultado de una carrera de caballos si la apuesta resultó ganadora. No es necesario que el predicado sea inversible.
*/

primero([Caballo | _], Caballo).
segundo([_ | [Caballo | _]], Caballo).

apuesta(ganador(Caballo), Resultado) :- primero(Resultado, Caballo).
apuesta(segundo(Caballo), Resultado) :- segundo(Resultado, Caballo).
apuesta(segundo(Caballo), Resultado) :- primero(Resultado, Caballo).
apuesta(exacta(Caballo, primero), Resultado) :- primero(Resultado, Caballo).
apuesta(exacta(Caballo, segundo), Resultado) :- segundo(Resultado, Caballo).
apuesta(imperfecta(Caballo, OtroCaballo), Resultado) :- primero(Resultado, Caballo), segundo(Resultado, OtroCaballo).
apuesta(imperfecta(Caballo, OtroCaballo), Resultado) :- primero(Resultado, OtroCaballo), segundo(Resultado, Caballo).


/*
Punto 6: Los colores (2 puntos)
Sabiendo que cada caballo tiene un color de crin:
Botafogo es tordo (negro)
Old Man es alazán (marrón)
Enérgica es ratonero (gris y negro)
Mat Boy es palomino (marrón y blanco)
Yatasto es pinto (blanco y marrón)
Queremos saber qué caballos podría comprar una persona que tiene preferencia por caballos de un color específico. Tiene que poder comprar por lo menos un caballo para que la solución sea válida. Ojo: no perder información que se da en el enunciado.
Por ejemplo: una persona que quiere comprar caballos marrones podría comprar a Old Man, Mat Boy y Yatasto. O a Old Man y Mat Boy. O a Old Man y Yatasto. O a Old Man. O a Mat Boy y Yatasto. O a Mat Boy. O a Yatasto.
*/

crin(botafogo, tordo).
crin(oldMan, alazan).
crin(energica, ratonero).
crin(matBoy, palomino).
crin(yatasto, pinto).

color(tordo, negro).
color(alazan, marron).
color(ratonero, gris).
color(ratonero, negro).
color(palomino, marron).
color(palomino, blanco).
color(pinto, Color) :- color(palomino, Color).


puedeComprar(Color, Caballos) :-
    findall(Caballo, (crin(Caballo, Crin), color(Crin, Color)), CaballosLista),
    combinacionesCaballos(Caballos, CaballosLista), length(Caballos, CantidadDeCaballos), CantidadDeCaballos >= 1.


combinacionesCaballos([], []).
combinacionesCaballos([Caballo | Caballos], [Caballo | CaballosLista]) :-
    combinacionesCaballos(Caballos, CaballosLista).
combinacionesCaballos(Caballos, [_ | CaballosLista]) :-
    combinacionesCaballos(Caballos, CaballosLista).