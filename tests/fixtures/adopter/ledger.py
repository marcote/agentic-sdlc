"""Sum a plain-text ledger read from stdin. One amount per line, blanks ignored."""
import sys


def total(lines):
    return sum(int(x) for x in lines if x.strip())


def main():
    print(total(sys.stdin.readlines()))


if __name__ == "__main__":
    main()
