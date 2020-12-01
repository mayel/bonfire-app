defmodule Bonfire.Repo.Migrations.ImportNotifications do
  use Ecto.Migration

  def change do
    Bonfire.Notifications.Migration.change()
  end

end
