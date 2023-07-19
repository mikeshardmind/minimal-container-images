# -*- coding: utf-8 -*- 
import apsw
import msgspec


if __name__ == "__main__":
    # not a real app, just here to show how this works.
    print("Native dependencies loaded fine")
    if __debug__:
        # we won't see this
        print(
            """PYTHONOPTIMIZE not set, asserts used for static typing
            and other cases will incur runtime costs"""
        )