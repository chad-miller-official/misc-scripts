#!/usr/bin/python

import random, sys

def main( argv ):
    try:
        lim = int( argv[0] )
    except ( IndexError, ValueError ):
        lim = 10

    for i in range( 0, lim ):
        num = random.randrange( -( 2 ** 31 ), ( 2 ** 31 ) - 1 )
        print( num )

if __name__ == '__main__':
    main( sys.argv[1:] )

sys.exit( 0 )
