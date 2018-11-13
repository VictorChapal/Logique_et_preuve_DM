#!/bin/bash

### Read the grid from standard input
OLDIFS="$IFS"
IFS="$IFS "

read N

declare -a WALLS

while read I J V || false; do
    WALLS[$((I*N+J))]=$V
done

IFS=$OLDIFS


### Variables propositionnelles
for I in `seq 0 $((N+1))`; do
    for J in `seq 0 $((N+1))`; do
        (declare-const bulb_${I}_${J} Bool)
        (declare-const wall_${I}_${J} Bool)
        (declare-const islit_${I}_${J} Bool)
    done
done

########################### Partie 2 ###########################

#contrainte n°1
(define-fun contrainte_1 () Bool
    (for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    (= islit_${I}_${J} true)
	done
    done))

#contrainte n°2
(define-fun contrainte_2 () Bool
    (iff (islit_${I}_${J})
	(or (bulb_${I}_${J})
	    (or (for I in `seq 1 $((N))`; do
		    (bulb_${I}_${J})))
	    done
	    (or (for J in `seq 1 $((N))`; do
		    (bulb_${I}_${J})))
	    done)))


#contraintes n° 3,5,6 ne sont pas faisable  dans cette section

#contraintes n°4
(define-fun contrainte_4 () Bool
    (implies (bulb_${I}_${J})
	(and (and (for I in `seq 1 $((N))`; do
		    (not bulb_${I}_${J})
		    done))
	    (and (for J in `seq 1 $((N))`; do
		    (not bulb_${I}_${J})
		    done)))))

 
########################### Partie 3 ###########################





########################### Partie 4 ###########################

########################### Partie 5 ###########################
 
