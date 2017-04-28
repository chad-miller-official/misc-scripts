#!/usr/bin/python

import sys

def get_next( fh, neg=False ):
    """Get the next positive or negative value
       in the file, depending on whether we want
       a positive or a negative number.

    Keyword arguments:
    fh  -- the file handle to read from
    neg -- True if we want the next negative
           value; False if we want the next
           positive value (default False)

    Return value: the next value in the file,
                  or None if there are none
                  left.
    """
    retval = None

    while retval is None:
        line = fh.readline()

        if not line:
            return None

        retval = int( line )

        # Skip the value we read if signage is incorrect
        if ( neg and retval > 0 ) or ( not neg and retval < 0 ):
            retval = None

    return retval

def usage():
    """Print the correct way to call this script."""
    print( 'Usage: {} <input file>'.format( sys.argv[0] ) )
    sys.exit( 0 )

def main( argv ):
    """Script main.

    Keyword arguments:
    argv -- an array containing this script arguments. Should
            contain only a filename at index 0.
    """
    if len( argv ) != 1:
        usage()

    filename = argv[0]

    pos_handle = open( filename, 'r' )
    neg_handle = open( filename, 'r' )

    total = next_pos = next_neg = 0

    # Our summing technique:
    # If the running total is positive, add a negative number to
    # it to avoid overflowing.
    # If the running total is negative, add a positive number to
    # it to avoid underflowing.
    while next_pos is not None or next_neg is not None:
        if total >= 0:
            if next_neg is None:
                # If the running total is positive but we are out of
                # positive numbers, the total will never be 0, so break
                break

            total    += next_neg
            next_neg  = get_next( neg_handle, True  )

        if total <= 0:
            if next_pos is None:
                # If the running total is negative but we are out of
                # negative numbers, the total will never be 0, so break
                break

            total    += next_pos
            next_pos  = get_next( pos_handle, False )

    pos_handle.close()
    neg_handle.close()

    print( 'true' if total == 0 else 'false' )

if __name__ == '__main__':
    main( sys.argv[1:] )

sys.exit( 0 )
