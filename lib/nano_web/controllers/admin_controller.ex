defmodule NanoWeb.AdminController do
  use NanoWeb, :controller

  alias Nano.Rooms
  alias Nano.Accounts
  alias Nano.ChatRooms

  plug :require_admin

  def dashboard(conn, _params) do
    users = Accounts.list_users()
    rooms = Rooms.list_rooms()
    render(conn, :dashboard, users: users, rooms: rooms)
  end

  ## Room related actions
  def new_room(conn, _params) do
    render(conn, :new_room)
  end

  def create_room(conn, %{"room" => room_params}) do
    case ChatRooms.create_room(room_params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error creating room.")
        |> redirect(to: ~p"/admin/rooms/new")
    end
  end

  def room_management(conn, %{"room_id" => room_id}) do
    room = Rooms.get_room!(room_id)
    questions = Rooms.list_room_questions(room_id)
    render(conn, :room_management, room: room, questions: questions)
  end

  def update_room(conn, %{"room_id" => room_id, "room" => room_params}) do
    room = Rooms.get_room!(room_id)

    case Rooms.update_room(room, room_params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room updated successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error updating room.")
        |> redirect(to: ~p"/admin/rooms/#{room.id}")
    end
  end

  ## Question related actions
  def create_question(conn, %{"room_id" => room_id, "question" => question_params}) do
    question_params = Map.put(question_params, "room_id", room_id)

    case Rooms.create_question(question_params) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error creating question.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  def update_question(conn, %{
        "room_id" => room_id,
        "question_id" => question_id,
        "question" => question_params
      }) do
    question = Rooms.get_question!(question_id)

    case Rooms.update_question(question, question_params) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error updating question.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  def send_question(conn, %{"room_id" => room_id, "question_id" => question_id}) do
    question = Rooms.get_question!(question_id)

    if question.is_active do
      Phoenix.PubSub.broadcast(
        Nano.PubSub,
        "room:#{room_id}:questions",
        {:question_activated, question}
      )

      conn
      |> put_flash(:info, "Question sent to room successfully.")
      |> redirect(to: ~p"/admin/rooms/#{room_id}/#questions")
    else
      conn
      |> put_flash(:error, "Cannot send inactive question to room.")
      |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  def activate_question(conn, %{"room_id" => room_id, "question_id" => question_id}) do
    question = Rooms.get_question!(question_id)

    case Rooms.activate_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question activated successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error activating question.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  def deactivate_question(conn, %{"room_id" => room_id, "question_id" => question_id}) do
    question = Rooms.get_question!(question_id)

    case Rooms.deactivate_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question deactivated successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error deactivating question.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  def delete_question(conn, %{"room_id" => room_id, "question_id" => question_id}) do
    question = Rooms.get_question!(question_id)

    case Rooms.delete_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question deleted successfully.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error deleting question.")
        |> redirect(to: ~p"/admin/rooms/#{room_id}")
    end
  end

  ## User related actions
  def make_admin(conn, %{"id" => user_id}) do
    user = Accounts.get_user!(user_id)

    case Accounts.update_user(user, %{role: "admin"}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User has been made an admin.")
        |> redirect(to: ~p"/admin")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error updating user role.")
        |> redirect(to: ~p"/admin")
    end
  end

  defp require_admin(conn, _opts) do
    if conn.assigns.current_user.role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
