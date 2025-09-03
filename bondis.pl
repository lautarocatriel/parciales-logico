/*
¡Pensando en el Bondi!

En todo el mundo se dice que el perro es el mejor amigo del hombre. Sin embargo, para nosotros en Argentina, en ciertas ocasiones, podríamos decir que el bondi es nuestro mejor amigo.

Por eso la empresa PdePasajeros, nos contrató para construir un modelo de sus flotas dentro del sistema Prolog

Cada línea de colectivo tiene su propio recorrido dentro del GBA (Gran Buenos Aires) o CABA (Ciudad Autónoma de Buenos Aires). El GBA se organiza en distintas zonas: sur, norte, oeste y este, donde cada línea se adapta a estas divisiones en su trayecto.

Base de conocimientos

Tenemos como punto de partida un predicado recorrido/3 que relaciona una línea con la información de su recorrido, especificando el área por la que pasa y la calle que atraviesa.

Ejemplo de la base de conocimiento:


% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido (152, gba(norte), olivos).

% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).



¡Nota importante! Resolver los siguientes requerimientos siguiendo las ideas del paradigma lógico. Asegurando que todos los predicados principales sean inversibles

*/

/*

1. Saber si dos líneas pueden combinarse, que se cumple cuando su recorrido pasa por una misma calle dentro de la misma zona.

*/
% recorrido/3 que relaciona una línea con la información de su recorrido, especificando el área por la que pasa y la calle que atraviesa.

% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).

% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).


combinacion(Linea, OtraLinea) :- recorrido(Linea, Zona, Calle), recorrido(OtraLinea, Zona, Calle), Linea \= OtraLinea.


/*
2.Conocer cuál es la jurisdicción de una línea, que puede ser o bien nacional, que se cumple cuando la misma cruza la General Paz,  o bien provincial, cuando no la cruza. Cuando la jurisdicción es provincial nos interesa conocer de qué provincia se trata, si es de buenosAires (cualquier parte de GBA se considera de esta provincia) o si es de caba. Se considera que una línea cruza la General Paz cuando parte de su recorrido pasa por una calle de CABA y otra parte por una calle del Gran Buenos Aires (sin importar de qué zona se trate).

*/

cruzaGeneralPaz(Linea) :- recorrido(Linea, caba, _), recorrido(Linea, gba(_), _).

jurisdiccion(Linea, nacional) :- cruzaGeneralPaz(Linea).
jurisdiccion(Linea, provincial(buenosAires)) :- recorrido(Linea, gba(_) , _), not(cruzaGeneralPaz(Linea)).
jurisdiccion(Linea, provincial(caba)) :- recorrido(Linea, caba, _), not(cruzaGeneralPaz(Linea)).


/*
Saber cuáles son las calles de transbordos en una zona, que son aquellas por las que pasan al menos 3 líneas de colectivos, y todas son de jurisdicción nacional.
*/

transbordos(Zona, Calle) :- recorrido(_, Zona, Calle), aggregate_all(count, (recorrido(Linea, Zona, Calle), cruzaGeneralPaz(Linea)), Cantidad),
Cantidad >= 3.


/*
Necesitamos incorporar a la base de conocimientos cuáles son los beneficios que las personas tienen asociadas a sus tarjetas registradas en el sistema SUBE. Dichos beneficios pueden ser cualquiera de los siguientes:
Estudiantil: el boleto tiene un costo fijo de $50.
Personal de casas particulares: nos interesará registrar para este beneficio cuál es la zona en la que se encuentra el domicilio laboral. Si la línea que se toma la persona con este beneficio pasa por dicha zona, se subsidia el valor total del boleto, por lo que no tiene costo.
Jubilado: el boleto cuesta la mitad de su valor.

	Sabemos que:
Pepito tiene el beneficio de personal de casas particulares dentro de la zona oeste del GBA.
Juanita tiene el beneficio del boleto estudiantil.
Tito no tiene ningún beneficio.
Marta tiene beneficio de jubilada y también de personal de casas particulares dentro de CABA y en zona sur del GBA.

a.Representar la información de los beneficios y beneficiarios.
b.Saber, para una persona, cuánto le costaría viajar en una línea, considerando que:
El valor normal del boleto (o sea, sin considerar beneficios) es de $500 si la línea es de jurisdicción nacional y de $350 si es provincial de CABA. En caso de ser de jurisdicción de la provincia de Buenos Aires, cuesta $25 multiplicado por la cantidad de calles que tiene en su recorrido más un plus de $50 si pasa por zonas diferentes de la provincia.
La persona debería abonar el valor que corresponda dependiendo de los beneficios que tenga. En caso de tener más de un beneficio, el monto a abonar debería ser el más bajo (los descuentos no son acumulativos). 

Por ejemplo, para Marta el boleto para una línea de jurisdicción nacional, dado que el mismo pasa por CABA sería gratuito por el beneficio de casas particulares, en cambio para una línea de jurisdicción de la provincia de Buenos Aires que pasa por zona norte y zona oeste únicamente, debería abonar la mitad de lo que cueste el viaje normal en esa línea, o sea ($50+$25*cantidad de calles del recorrido) / 2, por el beneficio de jubilada.
c.Si se quisiera agregar otro posible beneficio (ej. por discapacidad), cuál sería el impacto en la solución desarrollada?


*/


beneficioSube(estudiantil, 50).
beneficioSube(personalDomestico(Zona, Linea), 0) :- recorrido(Linea, Zona, _).
beneficioSube(jubilado, Precio) :- Precio is Precio /2.

beneficiario(pepito, personalDomestico(gba(oeste), _)).
beneficiario(juanita, estudiantil).
beneficiario(marta, jubilada).
beneficiario(marta, personalDomestico(caba, _)).
beneficiario(marta, personalDomestico(gba(sur), _)).

