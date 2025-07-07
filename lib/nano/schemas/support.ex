defmodule Nano.Schemas.Support do
  use Nano.Schema

  typed_schema "support_req" do
    field :name, :string
    field :email, :string
    field :subject, :string
    field :message, :string
  end

  def new(params) do
    %Nano.Schemas.Support{}
    |> cast(params, [:name, :email, :subject, :message])
  end

  def changeset(params) do
    %Nano.Schemas.Support{}
    |> cast(params, [:name, :email, :subject, :message])
    |> validate_required([:name, :email, :subject, :message])
    |> update_change(:email, &String.downcase/1)
    |> validate_email(:email)
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:subject, min: 3, max: 100)
    |> validate_length(:message, min: 10, max: 500)
  end

  defp validate_email(changeset, field) do
    changeset
    |> ensure_trimmed(field)
    |> validate_change(field, fn ^field, email ->
      if EmailChecker.valid?(email), do: [], else: [email: "is invalid"]
    end)
    |> validate_length(field, max: 160)
  end

  @spec ensure_trimmed(changeset :: Ecto.Changeset.t(), field :: atom() | [atom()]) ::
          Ecto.Changeset.t()
  defp ensure_trimmed(changeset, field) when is_atom(field) do
    update_change(changeset, field, &trim/1)
  end

  defp ensure_trimmed(changeset, fields) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      update_change(cs, field, &trim/1)
    end)
  end

  defp trim(str) when is_nil(str), do: str
  defp trim(str) when is_binary(str), do: String.trim(str)
end
