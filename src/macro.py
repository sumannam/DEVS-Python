from unittest import TestCase

class MyTests(TestCase):
    def test_one_plus_two(self):
        self.assertGreater(1, 2)
        self.assertEqual(1 + 2, 3)

def PRINT_ASSERT_RESULT(rtn):
    if rtn is False:
        print("ERROR")

def ASSERT_PARAM_EQUAL(a, b):
    rtn_equal = None

    if a is b:
        rtn_equal = True
    else:
        rtn_equal = False
    
    PRINT_ASSERT_RESULT(rtn_equal)
    


if __name__ == '__main__':
    ASSERT_PARAM_EQUAL(1, 2)
    # ASSERT_PARAM(1, 'num1 < 0') 