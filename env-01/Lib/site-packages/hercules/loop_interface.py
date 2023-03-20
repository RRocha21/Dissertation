import contextlib


class IteratorWrapperBase(object):

    def __init__(self, iterator):
        self.iterator = iterator
        self.counter = 0

    def __iter__(self):
        while True:
            try:
                yield self.next()
            except StopIteration:
                return

    def next(self):
        return next(self.iterator)


class ListIteratorBase(list):

    def __init__(self, listy):
        self.listy = listy
        self.counter = 0

    def __iter__(self):
        while True:
            try:
                yield self.next()
            except StopIteration:
                return

    def next(self):
        try:
            val = self.listy[self.counter]
        except IndexError:
            raise StopIteration()
        try:
            return val
        finally:
            self.counter += 1


class LoopInterface(ListIteratorBase):
    '''A listy context manager wrapper that enables things like:

    listy = ['A', 'B', 'C']
    >>> with LoopInterface(listy) as loop:
    ... for thing in loop:
    ...     if loop.first:
    ...         pass
    ...     elif loop.last:
    ...         print ', and',
    ...     else:
    ...         print ',',
    ...     print thing, "(%s)" % loop.counter,
    ...     if loop.last:
    ...         print '.'
    >>> A (1) , B (2) , and C (3) .
    '''
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        pass

    @property
    def first(self):
        return self.counter == 1

    @property
    def last(self):
        return self.counter == len(self.listy)

    @property
    def counter0(self):
        '''0-based loop counter.
        '''
        return self.counter - 1


def loop(*args, **kwargs):
    return LoopInterface(*args, **kwargs)