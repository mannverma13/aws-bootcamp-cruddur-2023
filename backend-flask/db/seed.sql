-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Andrew Brown','andrew@exampro.co' , 'mannverma' ,'MOCK'),
  ('Andrew Bayko','bayko@exampro.co' , 'manu' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'mannverma' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )