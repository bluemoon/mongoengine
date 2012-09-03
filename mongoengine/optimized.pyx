from bson.dbref import DBRef
import operator


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




def complex_base_field_to_mongo(cls, value):
    """Convert a Python type to a MongoDB-compatible type.
    """
    from mongoengine import Document

    if isinstance(value, basestring):
        return value

    if hasattr(value, 'to_mongo'):
        return value.to_mongo()

    is_list = False
    if not hasattr(value, 'items'):
        try:
            is_list = True
            value = dict([(k, v) for k, v in enumerate(value)])
        except TypeError:  # Not iterable return the value
            return value

    if cls.field:
        value_dict = dict([(key, cls.field.to_mongo(item)) for key, item in value.items()])
    else:
        value_dict = {}
        for k, v in value.items():
            if isinstance(v, Document):
                # We need the id from the saved object to create the DBRef
                if v.pk is None:
                    cls.error('You can only reference documents once they'
                               ' have been saved to the database')

                # If its a document that is not inheritable it won't have
                # _types / _cls data so make it a generic reference allows
                # us to dereference
                meta = getattr(v, 'meta', getattr(v, '_meta', {}))
                if meta and not meta.get('allow_inheritance', True) and not cls.field:
                    from fields import GenericReferenceField
                    value_dict[k] = GenericReferenceField().to_mongo(v)
                else:
                    collection = v._get_collection_name()
                    value_dict[k] = DBRef(collection, v.pk)
            elif hasattr(v, 'to_mongo'):
                value_dict[k] = v.to_mongo()
            else:
                value_dict[k] = cls.to_mongo(v)

    if is_list:  # Convert back to a list
        return [v for k, v in sorted(value_dict.items(), key=operator.itemgetter(0))]
    return value_dict