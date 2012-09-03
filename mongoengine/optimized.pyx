def _leading_zero(number):
    """
    Converts the given number to a string.

    If it has only one digit, a leading zero so as it has always at least
    two digits.
    """
    if int(number) < 10:
        return "0%s" % number
    else:
        return str(number)


def _convert_from_datetime(cls, val):
    """
    Convert a `datetime` object to a string representation (which will be
    stored in MongoDB). This is the reverse function of
    `_convert_from_string`.

    >>> a = datetime(2011, 6, 8, 20, 26, 24, 192284)
    >>> RealDateTimeField()._convert_from_datetime(a)
    '2011,06,08,20,26,24,192284'
    """
    data = []
    for name in cls.names:
        data.append(_leading_zero(getattr(val, name)))
    return ','.join(data)