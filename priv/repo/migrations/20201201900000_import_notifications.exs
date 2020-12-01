defmodule Bonfire.Repo.Migrations.ImportNotifications do
  use Ecto.Migration

  def up do
    Bonfire.Notifications.Migration.up()
  end

  def down do
    Bonfire.Notifications.Migration.down()
  end

end
