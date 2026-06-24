Da OAuth per MagicLink in der Email unter Windows schwierig ist, soll der Login angepasst werden, um Kompatibilitätsprobleme bei der Nutzung auf mehreren Plattformen zu vermeiden.

Hierzu gibt es in der "login_screen.dart" zwei neue Funktionen.

- signInWithDiscord
- _signUpWithEmail

Gleichzeitig wurde in der public.profiles ein neuer Eintrag hinzugefügt "is_enabled"

create table public.profiles (
  id uuid not null,
  updated_at timestamp with time zone null,
  username text null,
  full_name text null,
  avatar_url text null,
  website text null,
  is_admin boolean null default false,
  is_authorized boolean null default false,
  soullight integer null default 0,
  user_group text null default 'none'::text,
  is_enabled boolean null default false,
  constraint profiles_pkey primary key (id),
  constraint profiles_username_key unique (username),
  constraint profiles_id_fkey foreign KEY (id) references auth.users (id),
  constraint username_length check ((char_length(username) >= 3))
) TABLESPACE pg_default;

Folgendes soll geschehen.
1. Die Funktionen "signInWithDiscord" und "_signUpWithEmail" werden in die login_screen.dart eingebunden, sodass ein Signup auf diese Weise ermöglicht wird.
2. Die Variable is_enabled aus der public.profiles wird in den Programmablauf dergestalt eingepflegt, dass ein Login erst ermöglicht wird, wenn sie "true" ist. Anderenfalls wird der Nutzer direkt wieder ausgeloggt und eine Warnmeldung ausgegeben.
3. Das Ganze ist zu testen und etwaige Bugs zu fixen.