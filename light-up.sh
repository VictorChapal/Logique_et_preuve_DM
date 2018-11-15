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
#def nowall
(define-fun nowall ((I Int) (J Int) (K Int) (L Int)) Bool
 (for m in `seq I K`; do
      for n in `seq J L`; do
	  (iff not wall_${m}_{n} true)
      done
  done
  ))

#def haswall
(define-fun haswall ((I Int) (J Int) (K Int) (L Int)) Bool
 (iff not nowall(I J K L) true))

#contrainte n°1
(implies (nowall(I J K L))
 (and (for m in `seq I K`; do
	   for n in `seq J L`; do
	       (islit_${m}_${n})
	   done
       done
  )))

#contrainte n°3
(implies (wall_${I}_${J})
 ((implies (or (for m in `seq 1 I`; do
		    (bulb_${m}_${J})done))
   (and (for m in `seq I $((N))`; do
		    (not islit_${m}_${J})
	 done)))
  and
  ((implies (or (for m in `seq I $((N))`; do
		    (bulb_${m}_${J})done))
   (and (for m in `seq 1 I`; do
		    (not islit_${m}_${J})
	 done)))
   and
   (implies (or (for n in `seq 1 J`; do
		    (bulb_${I}_${n})done))
   (and (for n in `seq J $((N))`; do
		    (not islit_${I}_${n})
	 done)))
   and
   (implies (or (for n in `seq J $((N))`; do
		    (bulb_${I}_${n})done))
   (and (for n in `seq 1 J`; do
		    (not islit_${I}_${n})
	 done))))))

#contrainte n°5
(implies (and (for I in `seq 1 $((N))`; do
		   for J in `seq 1 $((N))`; do
		       (wall_${I}_${J})
		   done
	       done))
 (not bulb_${I}_${J}))



########################### Partie 4 ###########################

########################### Partie 5 ###########################
 
