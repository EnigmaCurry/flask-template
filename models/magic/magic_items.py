from .magic_model import MagicalItem
import datetime
from uuid import UUID

amulet_of_yendor = MagicalItem(
    id="8060f5b8-52d9-42dc-8b8a-2e5bdc2abf5b",
    name="Amulet of Yendor",
)


def _test_items():
    """
    >>> (amulet_of_yendor.name, amulet_of_yendor.id)
    ('Amulet of Yendor', UUID('8060f5b8-52d9-42dc-8b8a-2e5bdc2abf5b'))
    """
