#!/bin/bash

###
# Generates a Z3 model for the Light Up game
# https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#7x7b20s4d0#363781524717867
#
# The board is an NxN grid. Each cell is either empty or contains a wall. The
# goal is to put light bulbs in empty cells in a such a way that all empty cells
# are lighten, and no light bulb is illumated by another light bulb. Walls may
# contain a number from 0 to 4, that sets the number of adjacent cells (N, E,
# S, W) that must contains a light bulb.
#
# Invoke as:
# cat my_grid.txt | ./light-up.sh
#
# Where my-grid.txt follows this file format:
#
# N
# i j value
# ...
# i j value
#
# where N defines the size NxN of the grid, 1 <= i,j <= N are cell coordinates
# and value belongs to 0,1,2,3,4,X. Each triple (i,j,value) defines a wall in
# cell (i,j) that must have value adjacent light bulbs. There is no constraint
# on the number of adjacent light bulbs if value is X.
#
# To simplify the program (in particular regarding cardinalities), we surround
# the grid with fictitious cells that acts as walls with no cardinality
# constraint (X). So the extended grid that is used in this script has size
# [0,N+1]*[0,N+1]. It contains the actual grid [1,N]*[1,N]. The other cells
# cannot contain a light bulb.
#
# We use the following propositional variables for 0 <= i,j <= N+1:
# - bulb_i_j "there is a light bulb in cell (i,j)"
# - wall_i_j "there is a wall in cell (i,j)"
# _ islit_i_j "the cell (i,j) is lit"

#########################################################################
## Le code suivant est à conserver: il lit la description de la grille au
## format ci-dessus et stocke les informations dans un tableau WALLS
#########################################################################

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
        echo "(declare-const bulb_${I}_${J} Bool)"
        echo "(declare-const wall_${I}_${J} Bool)"
        echo "(declare-const islit_${I}_${J} Bool)"
    done
done


########################################################################
## Les exemples suivants montrent des détails de programmation BASH pour
## vous aider dans la réalisation de votre script. Ce code doit être
## retiré
########################################################################

### Comment lire le tableau de murs construit ci-dessus
for I in `seq 1 $N`; do
    for J in `seq 1 $N`; do
        if [ "${WALLS[$((I*N+J))]}" = "" ]; then
            echo "Pas de mur en ($I,$J)"
        else
            echo "Mur en ($I,$J)  avec valeur ${WALLS[$((I*N+J))]}"
        fi
    done
done

### Attention, les variables sont globales par défaut
I=1
echo "global, I=$I"

function f()
{
    I=2  # Modifie la variable globale I
    echo "dans f, I=$I"
}

f
echo "global, I=$I"

function g()
{
    for I in `seq 3 7`; do  # Modifie également la variable globale I
        echo "dans g, I=$I"
    done
}

g
echo "global, I=$I"

function h()
{
    local I   # Cette fois I est une variable locale
    for I in `seq 1 2`; do
        echo "dans h, I=$I"
    done
}

h
echo "global, I=$I"

### Appel de fonctions paramétrés
### Parfois, il est pratique de découper une fonction f qui prend en paramètre
### une valeur N (disons, entre 0 et 2) en 5 fonctions f0, f1, f2, f3, f4. Cela
### évite d'avoir une grosse fonction qui consiste essentiellement en une
### instruction if. En BASH, il est possible de faire la chose suivante:

function f0()
{
    echo "dans f0"
}

function f1()
{
    echo "dans f1"
}

function f2()
{
    echo "dans f2"
}

function f3()
{
    echo "dans f3"
}

function f4()
{
    echo "dans f4"
}

N=2
f$N

N=3
f$N
