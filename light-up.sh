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
        echo "declare-const bulb_${I}_${J} Bool"
        echo "declare-const wall_${I}_${J} Bool"
        echo "declare-const islit_${I}_${J} Bool"
    done
done

#Déclaration murs contours
for I in `seq 0 $((N+1))`; do
    echo "(assert wall_${I}_0)"
    echo "(assert wall_${I}_$((N+1)))"
done

for J in `seq 1 $((N))`; do
    echo "(assert wall_0_${J})"
    echo "(assert wall_$((N+1))_${J})"
done

### Comment lire le tableau de murs construit ci-dessus
for I in `seq 1 $N`; do
    for J in `seq 1 $N`; do
        if [ "${WALLS[$((I*N+J))]}" = "" ]; then
           # echo "Pas de mur en ($I,$J)"
        else
            #echo "Mur en ($I,$J)  avec valeur ${WALLS[$((I*N+J))]}"
	    #mettre cardinalite
	    echo "(assert (wall_${I}_${J}))"
        fi
    done
done
    
########################### Partie 2 ###########################

#contrainte n°1
function contrainte_1_V1(){
    for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    echo "(assert islit_${I}_${J})"
	done
    done
}

contrainte_1_V1 # appelle la contrainte 1

#contrainte n°2
function contrainte_2_V1(){
    for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    echo "(assert 
  (iff "  	 
	    echo "    (islit_${I}_${J})
    (or (bulb_${I}_${J})
        (or "
	    for M in `seq 1 $((N))`; do
		if [ $M -ne $I ]
		then
		    echo "            (bulb_${M}_${J})"
		fi
	    done
	    echo "        )"
	    echo "        (or "
	    for P in `seq 1 $((N))`; do
		if [ $P -ne $J ]
		then
		    echo "            (bulb_${I}_${P})"
		fi
	    done
    echo "        )
    )
  )
)"
	done
    done
    
}

contrainte_2_V1 # appelle la contrainte 2

#contraintes n° 3,5,6 concernent les murs, nous ne les traitons pas dans cette section

#contraintes n°4
function contrainte_4_V1(){
    for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    echo "(assert
  (implies (bulb_${I}_${J})"
	    echo "    (and (and "
	    for M in `seq 1 $((N))`; do
		if [ $M -ne $I ]
		then
		    echo "           (not bulb_${M}_${J})"
		fi
	    done
	    echo "         )"
	    echo "         (and "
	    for P in `seq 1 $((N))`; do
		if [ $P -ne $J ]
		then
		    echo "           (not bulb_${I}_${P})"
		fi
	    done
	    echo "         )"
    echo "    )
  )
)"
	done
    done
}

contrainte_4_V1 # appelle la contrainte 4

########################### Partie 3 ###########################
#def nowall, on l'appel en donnant en parametre I J K L
function nowall(){
    I=$1
    J=$2
    K=$3
    L=$4
    for M in `seq $I $K`; do
	for P in `seq $J $L`; do
	    echo "(assert not wall_${M}_${P})"
	done
    done
}
#nowall 1 1 3 3

#def haswall
function haswall(){
    I=$1
    J=$2
    K=$3
    L=$4
    for M in `seq $I $K`; do
	for P in `seq $J $L`; do
	    echo "(assert (not"
	    nowall $I $J $K $L
	    echo "))"
	done
    done
}
#haswall 1 1 3 3 

#contrainte n°1
function contrainte_1_V2(){
echo"(implies (nowall(I J K L))
 (and ("
for M in `seq I K`; do
    for P in `seq J L`; do
	echo"	       (islit_${M}_${P})"
    done
done
echo"  )))"
}

#contrainte n°3
function contrainte_3_V2(){
    for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    echo "(assert
  (implies (wall_${I}_${J})
    ("
	    echo "      (implies 
        (or "
	    for M in `seq 1 $((I-1))`; do
		echo "          (bulb_${M}_${J})"
	    done
	    echo "        )"
	    echo "        (and("
	    for M in `seq $((I+1)) $((N))`; do
		echo "          (not islit_${M}_${J})"
	    done
	    echo "        ))
      )"
	    echo "      and"
	    echo "      (implies 
        (or "
	    for M in `seq $((I+1)) $((N))`; do
		echo "          (bulb_${M}_${J})"
	    done
	    echo "        )"
	    echo "        (and("
	    for M in `seq 1 $((I-1))`; do
		echo "          (not islit_${M}_${J})"
	    done
	    echo "        ))
      )"
	    echo "      and"
	    echo "      (implies 
        (or "
	    for P in `seq 1 $((J-1))`; do
		echo "          (bulb_${I}_${P})"
	    done
	    echo "        )"
	    echo "        (and("
	    for P in `seq $((J+1)) $((N))`; do
		echo "          (not islit_${I}_${P})"
	    done
	    echo "        ))
      )"
	    echo "      and"
	    echo "      (implies 
        (or "
	    for P in `seq $((J+1)) $((N))`; do
		echo "          (bulb_${I}_${P})"
	    done
	    echo "        )"
	    echo "        (and("
	    for P in `seq 1 $((J-1))`; do
		echo "          (not islit_${I}_${P})"
	    done
	    echo "        ))
      )"
	    echo "    )
  )
)"
	done
    done
}
contrainte_3_V2

#contrainte n°5
function contrainte_5_V2(){
    for I in `seq 0 $((N+1))`; do
	for J in `seq 0 $((N+1))`; do
	    echo "(assert"
	    echo "  (implies "
	    echo "      (wall_${I}_${J})"
	    echo "      (not bulb_${I}_${J}))"
	    echo "    )
)"
		   done
    done
	  
}
contrainte_5_V2

########################### Partie 4 ###########################
function card_0(){
    I=$1
    J=$2
    echo "(assert (not bulb_${I}_${J}))" 
}

function card_1(){
    I=$1
    J=$2
    echo "(assert bulb_${I}_${J})" 
}

function card_bool(){
    echo ""
}

########################### Partie 5 ###########################
echo "(check-sat)"
echo "(get-model)"
