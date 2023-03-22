# Week 4 — Postgres and RDS
PostgreSQL is a popular open-source relational database management system (RDBMS) that is widely used by developers and organizations. Amazon Web Services (AWS) provides a managed PostgreSQL database service called Amazon RDS (Relational Database Service), which makes it easy to set up, operate, and scale PostgreSQL databases in the cloud.

Amazon RDS for PostgreSQL provides several benefits to users, including automatic backups, automated software patching, and replication for high availability. It also supports Amazon Aurora PostgreSQL, which is a highly scalable and performance-optimized version of PostgreSQL.

With Amazon RDS for PostgreSQL, you can choose the instance type, storage capacity, and other configuration settings that best fit your application requirements. You can also easily scale up or down your PostgreSQL database based on changing workload demands.

One of the key advantages of using Amazon RDS for PostgreSQL is that it takes care of many of the routine database management tasks, such as backups, patching, and monitoring, allowing you to focus on developing your application. Additionally, AWS provides several tools and services to help you manage your PostgreSQL databases, including Amazon CloudWatch for monitoring, AWS Database Migration Service for migrating data, and AWS Schema Conversion Tool for converting database schemas.

# Setting RDS Instance In AWS By Using Cli
1. select your zone in aws --> us-east-1
2. paste code into cli and hit enter
```
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username cruddurroot \
  --master-user-password <enter password min 8 characters> \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```
3. verify the database created in AWS console.

![image rds db ](assets/week4/rds-creation-console.jpg)

5. Check if you have a running connection to your PostgreSQL in cli
```
psql -Upostgres --host localhost
```
7. Create a DB in postgreSQL
```
CREATE database cruddur;
```

8. In IDE(vs code) backend-flask create a new folder --> db --> new file --> schema.sql
9. schema.sql code
```
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;


CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text NOT NULL,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

export the test url and gp to set in GITPOD veraible.
```
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```

15 Setup connection for the RDS INSTANCE --> cli
```
export PROD_CONNECTION_URL="postgresql://root:<PASSWORD>@<ENTER DATA BASE ENDPOINT AND PORT FROM AWS>RDS:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://root:<PASSWORD>@<ENTER DATA BASE ENDPOINT AND PORT FROM AWS>RDS:5432/cruddur"
```

17. Create bash scripts to connect db , create db and scmea load

*db-create
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

echo "db-create"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"
```
*db-drop
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-drop"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

echo "db-drop"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "drop database cruddur;"
```
*db-schema-load
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"
echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```
18.WE need permission to run thse scripts. Chmod command is used to  provide write access to run these scripts.

```
chmod u+x bin/db-create
chmod u+x bin/db-drop
chmod u+x bin/db-schema-load
```

21. run command to schema --> ./bin/db-schema-load --> this should create the tables from the schema


![image local db ](assets/week4/db-create.png)

25. check if tables exist --> \dt.

![image local db ](assets/week4/table-created.png)


27. create a new inside db --> seed.sql
```
-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Jess BK', 'jess-bk' , 'jessbk@hotmail.com', 'MOCK'),
  ('Andrew Bayko', 'bayko' , 'test@test.com', 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'jess-bk' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
```
26. create a new file in bin folder --> db-seed  . thsi script is use to insert data in table.
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"
echo $seed_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
```

To check the data if insterted to table , run below query 
connect to db- ./bin/db-connect 
\dt --> SELECT * FROM activities; 

to check the data in more readable format type --> \x on 
and then run query --> SELECT * FROM activities; 

![image rds](assets/week4aws/x-on-postgress.png)

# To check ho many db sessions we have opened. we create a script and saved as db-sesssions
This script give us details fo all db sessions we have created.

```
#! /usr/bin/bash
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

![image rds](assets/week4aws/db-sessions.png)

# To run complete db scripts in one go we create a db-setup script. 
This scriot will drop table if created  and then create sb, create schemas and insert data to the tables.

```
#! /usr/bin/bash
-e # stop if it fails at any point

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```


# Installing Drivers For PostgreSQL
1. add the packages to the requirements.txt file.
```
psycopg[binary]
psycopg[pool]
```
2. now install the packages by running the command in cli.
```
pip install -r requirements.txt
```

# Connection to postgres db in RDS
Setup a new inboud rule in database created which will allow Gitpod to the database in AWS.

# Modify the security groups in AWS
We have created a bash script to update IP address of Girpod in AWS database inbound rule automatically.

1.Run below command to set security group id and rule in gitpod env.
```
export DB_SG_ID="<Add the security group id here from AWS>"
gp env DB_SG_ID="<Add the security group id here from AWS>"

export DB_SG_RULE_ID="<Add the security group rule here from AWS>"
gp env DB_SG_RULE_ID="<Add the security group rule here from AWS>"
```
2. now set the modified security rules --> paste into cli and hit enter.
* first run export GITPOD_IP=$(curl ifconfig.me) in cli and then paste the code in cli 
```
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```
* db-rds-update-sg-rule
```
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="rds-update-sg-rule"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```
4. set the env var's for GITPOD.
```
export GITPOD_IP=$(curl ifconfig.me)
```
6. Update GITPOD yaml file to run the script everytime Gitpod starts.
```
command: |
  export GITPOD_IP=$(curl ifconfig.me)
  source  "$THEIA_WORKSPACE_ROOT/backend-flask/bin/db-rds-update-sg-rule"
```
 
![image Gitpod ip](assets/week4/Gitpod_IP_setup.jpg)

 
# Cognito Post Confirmation Lambda
Implementing custom authorizer for congito for user to be inserted into db.
Create a Lambda Function in AWS  python as language.
1. AWS ---> Lambda --> create a function.
2. Author from scratch
3. Function name --> cruddur-post-confirmation.
4. Runtime --> Python 3.8.
5. Architecture --> x86_64.
6. Change default execution role --> create a new role basic lambda permissions.
7. Advanced settings --> as default.
8. create function

# Create a new folder in backend-flask aws --> lambdas and add file name --> cruddur-post-confirrmation.py
```
import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)

    user_display_name  = user['name']
    user_email         = user['email']
    user_handle        = user['preferred_username']
    user_cognito_id    = user['sub']
    try:
      print('entered-try')
      sql = f"""
         INSERT INTO public.users (
          display_name, 
          email,
          handle, 
          cognito_user_id
          ) 
        VALUES(
        '{user_display_name}',
        '{user_email}',
        '{user_handle}',
        '{user_cognito_id}'
        )
      """
      print('SQL Statement ----')
      print(sql)
      conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
      cur = conn.cursor()
      cur.execute(sql)
      conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
      print(error)
    finally:
      if conn is not None:
          cur.close()
          conn.close()
          print('Database connection closed.')
    return event
```

## Lambda Function need to update below properties.
1. Edit Environment Variables --> key - CONNECTION_URL --> value - enter prod_connection_url value here 
2. Code Source --> paste in the code from --> cruddur-post-confirrmation.py
3. Add Lambda Layer as in the tutorial .

## Add lambda function as trigger to the cognitio user pool
5. Add Trigger to Congnito --> cruddur-user-pool --> User Pool Properties tab ---> Lambda Triggers.
6. Add Lambda Trigger --> Sign-up --> Post confirmation trigger.
7. Lambda Function --> Assign Lambda Function --> select --> one you created earlier.
8. Add Lamdba Trigger.

##  update permissions , and add EC@ role execution role 
Create Permission for user for EC2 instance for VPC --> Create Role Policy --> Open Lamdba in AWS console
11. Configuration tab --> Permissions --> click on Execution roles --> cruddur.
12. Permission Policies -->  Policies --> Create Policy --> JSON
```

Create a user and check if user get create in database. Functio will get trigger post singup confirmation.

![image Gitpod ip](assets/week4/insert-post-cognito-lambda.jpg)

# Create Activites
The following is all the updates i needed to make to create the implementation of user to create a message on the frontend
* first all the updates made on the backend-flask
1. update lambda function and upload to AWS Lambda function and deploy.
```
import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)

    user_display_name  = user['name']
    user_email         = user['email']
    user_handle        = user['preferred_username']
    user_cognito_id    = user['sub']
    try:
      print('entered-try')
      sql = f"""
         INSERT INTO public.users (
          display_name, 
          email,
          handle, 
          cognito_user_id
          ) 
        VALUES(%s,%s,%s,%s)
      """
      print('SQL Statement ----')
      print(sql)
      conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
      cur = conn.cursor()
      params = [
        user_display_name,
        user_email,
        user_handle,
        user_cognito_id
      ]
      cur.execute(sql,params)
      conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
      print(error)
    finally:
      if conn is not None:
          cur.close()
          conn.close()
          print('Database connection closed.')
    return event
```

2. updated schema.sql

-- https://www.postgresql.org/docs/current/uuid-ossp.html
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- forcefully drop our tables if they already exist
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;
object
CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text NOT NULL,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);


CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

3. created folder inside db sql/activites --> created three files home.sql, object.sql, create.sql.
* create.sql
```
INSERT INTO public.activities (
  user_uuid,
  message,
  expires_at
)
VALUES (
  (SELECT uuid 
    FROM public.users 
    WHERE users.handle = %(handle)s
    LIMIT 1
  ),
  %(message)s,
  %(expires_at)s
) RETURNING uuid;
```
* home.sql
```
SELECT
  activities.uuid,
  users.display_name,
  users.handle,
  activities.message,
  activities.replies_count,
  activities.reposts_count,
  activities.likes_count,
  activities.reply_to_activity_uuid,
  activities.expires_at,
  activities.created_at
FROM public.activities
LEFT JOIN public.users ON users.uuid = activities.user_uuid
ORDER BY activities.created_at DESC
```
* object.sql

```
SELECT
  activities.uuid,
  users.display_name,
  users.handle,
  activities.message,
  activities.created_at,
  activities.expires_at
FROM public.activities
INNER JOIN public.users ON users.uuid = activities.user_uuid 
WHERE 
  activities.uuid = %(uuid)s
```
4. Updated db.py file inside lib folder

```
from psycopg_pool import ConnectionPool
import os
import re
import sys
from flask import current_app as app

class Db:
  def __init__(self):
    self.init_pool()

  def template(self,*args):
    pathing = list((app.root_path,'db','sql',) + args)
    pathing[-1] = pathing[-1] + ".sql"

    template_path = os.path.join(*pathing)

    green = '\033[92m'
    no_color = '\033[0m'
    print("\n")
    print(f'{green} Load SQL Template: {template_path} {no_color}')

    with open(template_path, 'r') as f:
      template_content = f.read()
    return template_content

  def init_pool(self):
    connection_url = os.getenv("CONNECTION_URL")
    self.pool = ConnectionPool(connection_url)
  # we want to commit data such as an insert
  # be sure to check for RETURNING in all uppercases
  def print_params(self,params):
    blue = '\033[94m'
    no_color = '\033[0m'
    print(f'{blue} SQL Params:{no_color}')
    for key, value in params.items():
      print(key, ":", value)

  def print_sql(self,title,sql):
    cyan = '\033[96m'
    no_color = '\033[0m'
    print(f'{cyan} SQL STATEMENT-[{title}]------{no_color}')
    print(sql)
  def query_commit(self,sql,params={}):
    self.print_sql('commit with returning',sql)

    pattern = r"\bRETURNING\b"
    is_returning_id = re.search(pattern, sql)

    try:
      with self.pool.connection() as conn:
        cur =  conn.cursor()
        cur.execute(sql,params)
        if is_returning_id:
          returning_id = cur.fetchone()[0]
        conn.commit() 
        if is_returning_id:
          return returning_id
    except Exception as err:
      self.print_sql_err(err)
  # when we want to return a json object
  def query_array_json(self,sql,params={}):
    self.print_sql('array',sql)

    wrapped_sql = self.query_wrap_array(sql)
    with self.pool.connection() as conn:
      with conn.cursor() as cur:
        cur.execute(wrapped_sql,params)
        json = cur.fetchone()
        return json[0]
  # When we want to return an array of json objects
  def query_object_json(self,sql,params={}):

    self.print_sql('json',sql)
    self.print_params(params)
    wrapped_sql = self.query_wrap_object(sql)

    with self.pool.connection() as conn:
      with conn.cursor() as cur:
        cur.execute(wrapped_sql,params)
        json = cur.fetchone()
        if json == None:
          "{}"
        else:
          return json[0]
  def query_wrap_object(self,template):
    sql = f"""
    (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
    {template}
    ) object_row);
    """
    return sql
  def query_wrap_array(self,template):
    sql = f"""
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
    {template}
    ) array_row);
    """
    return sql
  def print_sql_err(self,err):
    # get details about the exception
    err_type, err_obj, traceback = sys.exc_info()

    # get the line number when exception occured
    line_num = traceback.tb_lineno

    # print the connect() error
    print ("\npsycopg ERROR:", err, "on line number:", line_num)
    print ("psycopg traceback:", traceback, "-- type:", err_type)

    # print the pgcode and pgerror exceptions
    print ("pgerror:", err.pgerror)
    print ("pgcode:", err.pgcode, "\n")

db = Db()
```

5. Updated create_activities in services

```
from datetime import datetime, timedelta, timezone

from lib.db import db

class CreateActivity:
  def run(message, user_handle, ttl):
    model = {
      'errors': None,
      'data': None
    }

    now = datetime.now(timezone.utc).astimezone()

    if (ttl == '30-days'):
      ttl_offset = timedelta(days=30) 
    elif (ttl == '7-days'):
      ttl_offset = timedelta(days=7) 
    elif (ttl == '3-days'):
      ttl_offset = timedelta(days=3) 
    elif (ttl == '1-day'):
      ttl_offset = timedelta(days=1) 
    elif (ttl == '12-hours'):
      ttl_offset = timedelta(hours=12) 
    elif (ttl == '3-hours'):
      ttl_offset = timedelta(hours=3) 
    elif (ttl == '1-hour'):
      ttl_offset = timedelta(hours=1) 
    else:
      model['errors'] = ['ttl_blank']

    if user_handle == None or len(user_handle) < 1:
      model['errors'] = ['user_handle_blank']

    if message == None or len(message) < 1:
      model['errors'] = ['message_blank'] 
    elif len(message) > 280:
      model['errors'] = ['message_exceed_max_chars'] 

    if model['errors']:
      model['data'] = {
        'handle':  user_handle,
        'message': message
      }   
    else:
      expires_at = (now + ttl_offset)
      uuid = CreateActivity.create_activity(user_handle,message,expires_at)

      object_json = CreateActivity.query_object_activity(uuid)
      model['data'] = object_json
    return model

  def create_activity(handle, message, expires_at):
    sql = db.template('activities','create')
    uuid = db.query_commit(sql,{
      'handle': handle,
      'message': message,
      'expires_at': expires_at
    })
    return uuid
  def query_object_activity(uuid):
    sql = db.template('activities','object')
    return db.query_object_json(sql,{
      'uuid': uuid
    })
```
6. Updated home_activities in services
```
from datetime import datetime, timedelta, timezone
from opentelemetry import trace

from lib.db import db

#tracer = trace.get_tracer("home.activities")

class HomeActivities:
  def run(cognito_user_id=None):
    #logger.info("HomeActivities")
    #with tracer.start_as_current_span("home-activites-mock-data"):
    #  span = trace.get_current_span()
    #  now = datetime.now(timezone.utc).astimezone()
    #  span.set_attribute("app.now", now.isoformat())
    sql = db.template('activities','home')
    results = db.query_array_json(sql)
    return results
```
7. Updated app.py
```
@app.route("/api/activities", methods=['POST','OPTIONS'])
@cross_origin()
def data_activities():
  user_handle = request.json["user_handle"]
  message = request.json['message']
  ttl = request.json['ttl']
  model = CreateActivity.run(message, user_handle, ttl)
  if model['errors'] is not None:
    return model['errors'], 422
  else:
    return model['data'], 200
  return
```
* Second all the updates made on the frontend
1. added response for the body to handle the user from the frontend for @handle in the components/ActivityForm.js 
```
body: JSON.stringify({
  user_handle: props.user_handle.handle,
  message: message,
  ttl: ttl,
}),
```
2. updated the props in pages/HomeFeedPage.js 
```
<ActivityForm
  user_handle={user}
  popped={popped}
  setPopped={setPopped}
  setActivities={setActivities}
/>
```
With all the implementation above i was able to create an activity.

![image rds activity](assets/week4/activity_created.jpg)

