import unittest

import ledger


class TotalTest(unittest.TestCase):
    def test_sums_and_ignores_blanks(self):
        self.assertEqual(ledger.total(["3", "", "4"]), 7)
