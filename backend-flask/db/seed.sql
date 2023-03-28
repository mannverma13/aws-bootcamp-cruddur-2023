-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Manish Verma','mvmanverma@gmail.com' , 'mannverma' ,'MOCK'),
  ('Manu sharma','manishverma978@gmail.com' , 'manu' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'mannverma' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )