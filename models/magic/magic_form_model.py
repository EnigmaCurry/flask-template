from flask_wtf import FlaskForm, Form
from wtforms import StringField
from wtforms.validators import DataRequired, Length

class MagicalItemForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired(), Length(min=3, max=35)])

