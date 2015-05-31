defmodule EdgeBuilder.Repo.Migrations.AddSlugsToCharacters do
  use Ecto.Migration

  def up do
    # NOTE: If this migration fails, you need to run the following as a super user:
    # CREATE EXTENSION IF NOT EXISTS pgcrypto

    execute "
      CREATE FUNCTION new_url_slug() RETURNS text AS $$
      DECLARE
        new_slug text;
        done bool;
      BEGIN
        done := false;
        WHILE NOT done LOOP
          new_slug := lower(substring(regexp_replace(encode(gen_random_bytes(32), 'base64'), '[^a-zA-Z0-9]+', '', 'g'), 0, 10));
          done := NOT exists(SELECT 1 FROM characters WHERE url_slug = new_slug);
        END LOOP;
        RETURN new_slug;
      END;
      $$ LANGUAGE PLPGSQL VOLATILE;
    "

    execute "ALTER TABLE characters ADD COLUMN url_slug varchar(10) DEFAULT new_url_slug()"

    execute "update characters set url_slug = new_url_slug()"
  end
end
