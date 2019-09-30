defmodule LiveViewDemo.SqlLab.QueryExecuter do
  alias LiveViewDemo.Repo

  @sql_filtered [
    "DROP",
    "drop",
    "DELETE",
    "delete",
    "UPDATE",
    "update",
    "INSERT",
    "insert",
    "LIKE",
    "like",
    "GRANT",
    "grant",
    "REVOKE",
    "revoke"
  ]

  def handle_sql_petition(petition),
    do: Repo.query(petition)

  def sanitize(petition) do
    if String.contains?(petition, @sql_filtered) do
      {:error, "Your query contains a prohibited operation. Please make only SELECT queries"}
    else
      :ok
    end
  end

  def format_result(%Postgrex.Result{columns: columns, rows: rows}),
    do: {columns, rows}

  def format_error(%Postgrex.Error{postgres: %{message: message}}),
    do: message

end
