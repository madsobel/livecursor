defmodule Cursor.Presence do
  use Phoenix.Presence, otp_app: :cursor, pubsub_server: Cursor.PubSub
end
