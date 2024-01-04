from flask import Flask, redirect
from lib.config import (
    logging,
    APP_PREFIX,
    HTTP_HOST,
    HTTP_PORT,
    DEPLOYMENT,
    LOG_LEVEL,
    APP_SECRET_KEY,
)

from routes import hello, magic

log = logging.getLogger("app")
app = Flask(__name__)
app.secret_key = APP_SECRET_KEY
app.register_blueprint(hello, url_prefix="/hello")
app.register_blueprint(magic, url_prefix="/magic")


@app.route("/", methods=["GET"])
def root():
    """Redirect the root page to the default blueprint"""
    return redirect("/hello")


log.debug(app.url_map)

if __name__ == "__main__":
    log.warning(
        f"{APP_PREFIX}_DEPLOYMENT={DEPLOYMENT} - Startup in {'LOCAL' if HTTP_HOST == '127.0.0.1' else 'PUBLIC'} {str(DEPLOYMENT)} mode"
    )
    app.run(host=HTTP_HOST, port=HTTP_PORT, debug=(DEPLOYMENT == "dev"))
