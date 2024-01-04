from datetime import datetime
from pydantic import BaseModel, Field, UUID4, field_validator
from typing_extensions import Annotated
from typing import Optional
from lib.db import db
import aiosql
import os
import json

## This model enforces a strict data format defined by the Pydantic data class: MagicalItem
## This model is used by the DB and for all backend app logic.
## The frontend uses the WTF Form model in magic_form_model.py
## which is then converted to/from this.

class MagicalItem(BaseModel):
    """Data model of a magical item

    >>> just_data = {'id': '9e495af2-5d5a-4fe6-8b45-3c1806fb02bb', 'name': 'Ring of See Invisible', 'created': '2023-07-29 07:30:45' }
    >>> now = datetime.now()
    >>> ring_of_see_invisibility = MagicalItem(**just_data)
    >>> str(ring_of_see_invisibility.id)
    '9e495af2-5d5a-4fe6-8b45-3c1806fb02bb'
    >>> [getattr(ring_of_see_invisibility.created, x) for x in ['year','month','day','hour','minute','second']]
    [2023, 7, 29, 7, 30, 45]
    >>> (ring_of_see_invisibility.cataloged - now).seconds == 0
    True
    """

    id: UUID4
    name: str
    created: Optional[datetime] = None
    destroyed: Optional[datetime] = None
    cataloged: Annotated[datetime, Field(validate_default=True)] = None

    @field_validator("cataloged", mode="before")
    @classmethod
    def set_cataloged(cls, cataloged):
        return cataloged or datetime.now()

    @field_validator("id", mode="before")
    @classmethod
    def set_id(cls, id):
        return id or uuid.uuid4()


class MagicalItemForm(BaseModel):
    """The form input data that will become a MagicalItem"""

    name: str

queries = aiosql.from_path(
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "magic.sql"),
    driver_adapter="sqlite3",
)


def create_tables_magic():
    with db() as conn:
        queries.create_table_magical_item(conn)


def save_magical_item(item: MagicalItem):
    with db() as conn:
        queries.save_magical_item(
            conn,
            id=str(item.id),
            name=item.name,
            created=item.created,
            destroyed=item.destroyed,
            cataloged=item.cataloged
        )


def get_magical_items() -> list[MagicalItem]:
    with db() as conn:
        return queries.get_magical_items(conn)


def get_magical_item_by_id(id) -> MagicalItem:
    with db() as conn:
        data = dict(
            zip(
                MagicalItem.model_fields.keys(),
                queries.get_magical_item_by_id(conn, id=str(id)),
            )
        )
        return MagicalItem(**data)
