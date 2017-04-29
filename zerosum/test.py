from zerosum import run

def test_neg():
    assert run( 'test/neg.txt' ) is False

def test_negs():
    assert run( 'test/negs.txt' ) is False

def test_pos():
    assert run( 'test/pos.txt' ) is False

def test_poses():
    assert run( 'test/poses.txt' ) is False

def test_random_big():
    assert run( 'test/random_big.txt' ) is False

def test_random_small():
    assert run( 'test/random_small.txt' ) is True

def test_zero():
    assert run( 'test/zero.txt' ) is True

def test_zeroes():
    assert run( 'test/zeroes.txt' ) is True

def test_zero_sum_1():
    assert run( 'test/zero_sum_1.txt' ) is True

def test_zero_sum_2():
    assert run( 'test/zero_sum_2.txt' ) is True

def test_zero_sum_3():
    assert run( 'test/zero_sum_3.txt' ) is True
