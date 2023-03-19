from datetime import datetime, timedelta, timezone

from lib.db import pool
class HomeActivities:
  def run(cognito_user_id=None):
  #def run(logger):
  #  logger.info("HomeActivities")
    now = datetime.now(timezone.utc).astimezone()
 
    sql = """
    SELECT * FROM activities
    """

    with pool.commection() as conn:
        with conn.cursor() as cur:
             cur.execute(sql)
             json = cur.fetchall()
    return json[0]
    return results