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


function declare_const(){
    local I
    local J
    for I in `seq 0 $((N+1))`; do
	for J in `seq 0 $((N+1))`; do
            echo "(declare-const bulb_${I}_${J} Bool)"
            echo "(declare-const wall_${I}_${J} Bool)"
            echo "(declare-const islit_${I}_${J} Bool)"
	done
    done
}

function declare_murs_contour(){
    local I
    local J
    for I in `seq 0 $((N+1))`; do
	echo "(assert (wall_${I}_0))"
	echo "(assert (wall_${I}_$((N+1))))"
    done
    
    for J in `seq 1 $((N))`; do
	echo "(assert (wall_0_${J}))"
	echo "(assert (wall_$((N+1))_${J}))"
    done
}

function declare_murs(){
    local I
    local J
    for I in `seq 1 $N`; do
	for J in `seq 1 $N`; do
            if [ "${WALLS[$((I*N+J))]}" != "" ]; then
		echo "(assert (wall_${I}_${J}))"
            fi
	done
    done
}

function declare_cardinalites(){
    for A in `seq 1 $N`; do
	for B in `seq 1 $N`; do
            if [ "${WALLS[$((A*N+B))]}" != "" ] && [ WALLS[$((A*N+B))] != "X" ]; then
		echo "je suis dans la fonction"
		contrainte_6_card_$((WALLS[$((A*N+B))])) $A $B
            fi
	done
    done
}
########################### Partie 2 ###########################

#contrainte n°1
function contrainte_1_V1(){
    local I
    local J
    for I in `seq 1 $((N))`; do
	for J in `seq 1 $((N))`; do
	    echo "(assert (islit_${I}_${J}))"
	done
    done
}


#contrainte n°2
function contrainte_2_V1(){
    local I
    local J
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


#contraintes n° 3,5,6 concernent les murs, nous ne les traitons pas dans cette section

#contraintes n°4
function contrainte_4_V1(){
    local I
    local J
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

########################### Partie 3 ###########################
#def nowall, on l'appel en donnant en parametre I J K L
function nowall(){
    A=$1
    B=$2
    K=$3
    L=$4
    for M in `seq $A $K`; do
	for P in `seq $B $L`; do
	    echo "                        (not wall_${M}_${P})"
	done
    done
}

#def haswall
function haswall(){
    A=$1
    B=$2
    K=$3
    L=$4
    if [ $A -gt $K ]; then
	tmp=$A
	A=$K
	K=$tmp
    fi
    if [ $B -gt $L ]; then
	tmp=$B
	B=$L
	L=$tmp
    fi
    echo "                     (not"
    nowall $A $B $K $L
    echo "                     )"
}


#contrainte n°1
function contrainte_1_V2(){
    for M in `seq 1 $((N))`; do
	for P in `seq 1 $((N))`; do
	    echo "(assert "
	    echo "  (implies "
	    echo "     (not wall_${M}_${P})"
	    echo "     (islit_${M}_${P})"
	    echo "  )"
	    echo ")"
	done
    done
}

#contrainte n°3
function contrainte_3_V2(){
    local I
    local J
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


#contrainte n°4
function contrainte_4_V2(){
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
	    echo "    )"
	    echo "    or("
	    for Q in `seq 1 $((N))`; do
		if [ $Q -ne $I ]
		then
		    echo "           (implies (bulb_${Q}_${J})"
		    echo "                    (or"
		    haswall $I $J $Q $J
		    echo "                    )"
		    echo "           )"
		fi
	    done
	    echo "    )"
	    echo "    or("
	    for R in `seq 1 $((N))`; do
		if [ $R -ne $J ]
		then
		    echo "           (implies (bulb_${I}_${R})"
		    echo "                    ("
		    haswall $I $J $I $R
		    echo "                    )"
		    echo "           )"
		fi
	    done
	    echo "    )"
	    echo "  )"
	    echo ")"
	done
    done
}


#contrainte n°5
function contrainte_5_V2(){
    for I in `seq 0 $((N+1))`; do
	for J in `seq 0 $((N+1))`; do
	    echo "(assert"
	    echo "  (implies "
	    echo "      (wall_${I}_${J})"
	    echo "      (not bulb_${I}_${J})"
	    echo "  )
)"
		   done
    done
	  
}



########################### Partie 4 ###########################
function card_0(){
    I=$1
    J=$2
    echo "         (not bulb_${I}_${J})" 
}


function card_1(){
    I=$1
    J=$2
    echo "         (bulb_${I}_${J})" 
}

function card_bool(){
    I=$1
    J=$2
    N=$3
    E=$4
    S=$5
    W=$6
    card_$N $((I-1)) $J
    card_$E $((I+1)) $((J+1))
    card_$S $((I+1)) $((J-1))
    card_$W $((I-1)) $((J-1))
}

function contrainte_6_card_0(){
    I=$1
    j=$2
    echo "(assert"
    echo "  (and ("
    card_bool $1 $2 0 0 0 0
    echo "      )"
    echo "  )"
    echo ")"
}


function contrainte_6_card_1(){
    I=$1
    j=$2
    echo "(assert"
    echo "  (or(and("
    card_bool $1 $2 1 0 0 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 1 0 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 0 1 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 0 0 1
    echo "         )"
    echo "      )"
    echo "  )"
    echo ")"
}


function contrainte_6_card_2(){
    I=$1
    j=$2
    echo "(assert"
    echo "  (or(and("
    card_bool $1 $2 1 1 0 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 1 0 1 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 1 0 0 1
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 1 1 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 1 0 1
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 0 1 1
    echo "         )"
    echo "      )"
    echo "  )"
    echo ")"
    
}


function contrainte_6_card_3(){
    I=$1
    j=$2
    echo "(assert"
    echo "  (or(and("
    card_bool $1 $2 1 1 1 0
    echo "         )"
    echo "     (and("
    card_bool $1 $2 1 1 0 1
    echo "         )"
    echo "     (and("
    card_bool $1 $2 1 0 1 1
    echo "         )"
    echo "     (and("
    card_bool $1 $2 0 1 1 1
    echo "         )"
    echo "      )"
    echo "  )"
    echo ")"
}


function contrainte_6_card_4(){
    I=$1
    j=$2
    echo "(assert"
    echo "  (and ("
    card_bool $1 $2 1 1 1 1
    echo "      )"
    echo "  )"
    echo ")"
}


########################### Partie 5 ###########################

function partie_2(){
    contrainte_1_V1
    contrainte_2_V1
    contrainte_4_V1
}

function partie_3(){
    contrainte_1_V2
    contrainte_2_V1
    contrainte_3_V2
    contrainte_4_V2
    contrainte_5_V2
}

function partie_4(){
    contrainte_1_V2
    contrainte_2_V1
    contrainte_3_V2
    contrainte_4_V2
    contrainte_5_V2
    declare_cardinalites
}

function main(){
    declare_const
    declare_murs_contour
    declare_murs
    partie_$1
}

main 3 # 2, 3 ou 4

echo "(check-sat)"
echo "(get-model)"
