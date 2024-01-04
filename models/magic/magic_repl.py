# import this into your REPL to play with the magic_model
# >>> from routes.hello.magic_repl import *

import sqlite3
from lib.db import db
from lib.config import DB
from .magic_model import *
import sys

conn = sqlite3.connect(DB)

just_data = {
    "id": "9e495af2-5d5a-4fe6-8b45-3c1806fb02bb",
    "name": "Ring of See Invisible",
    "powers": {"shield": 1},
    "abilities": {"reveal": ["Phantom", "Croseus"]},
    "created": "2023-07-29 07:30:45",
}

ring_of_see_invisibility = MagicalItem(**just_data)

if DB == ":memory:" and bool(getattr(sys, "ps1", sys.flags.interactive)):
    create_tables_magic()
    save_magical_item(ring_of_see_invisibility)
    print("Created magic tables and test data in in-memory database")
