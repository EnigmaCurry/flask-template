from flask import request, Blueprint, session, abort
from jinja2 import TemplateNotFound
from models.magic import create_tables_magic, get_magical_items, MagicalItem, MagicalItemForm
from lib.config import WERKZEUG_RELOADING
from lib.template import render
from lib.date import parse_datetime_local
from flask_pydantic import validate


magic = Blueprint("magic", __name__, template_folder="templates")


@magic.record_once
def init(context):
    """Initialize the magic module ONCE on app startup"""
    # Only run this in the main flask thread, not the workzeug reloader, otherwise this might be called twice:
    ## https://stackoverflow.com/questions/25504149/why-does-running-the-flask-dev-server-run-itself-twice/25504196#25504196
    if not WERKZEUG_RELOADING:
        create_tables_magic()


@magic.route("/")
def list_magic_items():
    """List of all magic items"""
    return render("magic/magic_item_list.html", magic_items=get_magical_items())


@magic.route("/item", methods=["GET"])
def get_form_create_magic_item():
    """Get the HTML form that creates new magic items"""
    form = MagicalItemForm()
    return render("magic/magic_item_form.html", form=form)


@magic.route("/item/<id>", methods=["GET"])
def get_magic_item(id):
    """Get the page that describes a single magic item"""
    item = MagicalItem(id=id, name="placeholder", powers={}, abilities={})
    return render("magic/magic_item.html", magic_item=item)


@magic.route("/item", methods=["POST"])
def create_magic_item():
    """Submit form to POST a new magic item and save it to the database"""
    item = MagicalItem(
        id="02e78c5b-5f45-40f8-96bd-9a2c6599ca51",
        created=parse_datetime_local(request.form["created"]),
        destroyed=parse_datetime_local(request.form["destroyed"]),
        name=request.form["name"],
        powers={},
        abilities={},
    )
    print(request.form)
    print(item)
    return render("magic/magic_item.html", magic_item=item)
