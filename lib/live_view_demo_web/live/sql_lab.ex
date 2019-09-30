defmodule LiveViewDemoWeb.SqlLab do
  use Phoenix.LiveView
  import Phoenix.HTML.Form

  alias LiveViewDemo.Queries.CommonQueries
  alias LiveViewDemo.SqlLab.{QueryExecuter, CsvDownload}

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems">
      <div>
        <h1>This is the SQL Lab</h1>
      </div>
      <div class="display-flex row">
        <div class="sql-lab-column column">
          <div>
            <h2>You can run the SELECT queries you'd like<h2>
          </div>
          <div class="sql-lab-column">
            <%= f = form_for :query_form, "#", [phx_submit: :submit_query] %>
              <%= textarea f, :query, value: @query, class: "sql-lab-text-area"%>
              <%= submit "Run", class: "blueButton" %>
            </form>
          </div>
          <div>
            <%= if @result do %>
            <div>
              <%= generate_results_table(@result) %>
            </div>
            <% else %>
              <%= if @error do %>
                <div>
                <%= generate_error(@error) %>
                </div>
              <% else %>
              <% end %>
            <% end %>
          </div>
        </div>
          <div class="tables-display">
            <h2> Available tables </h2>
            <%= generate_tables_display(@tables) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    tables = CommonQueries.get_public_tables()
    |> Enum.map(&format_tables_and_columns/1)

    {:ok, put_initial_assigns(socket, tables)}
  end

  def handle_event("submit_query", %{"query_form" => %{"query" => query}}, socket) do
    case QueryExecuter.sanitize(query) do
      {:error, error} ->
        {:noreply, assign(socket, result: nil, query: query, error: error)}
      :ok -> handle_sql_petition(socket, query)
    end
  end

  defp handle_sql_petition(socket, query) do
    case QueryExecuter.handle_sql_petition(query) do
      {:ok, result} ->
        formatted_result = QueryExecuter.format_result(result)
        {:noreply, assign(socket, result: formatted_result, query: query, error: nil)}

      {:error, error} ->
        formatted_error = QueryExecuter.format_error(error)
        {:noreply, assign(socket, result: nil, query: query, error: formatted_error)}
    end
  end

  defp format_tables_and_columns(table) do
    columns = CommonQueries.get_table_columns(table)

    {table, columns}
  end

  defp put_initial_assigns(socket, tables) do
    assign(socket, result: nil, query: "", error: nil, tables: tables)
  end

  defp generate_results_table({columns, rows}) when is_list(columns) and is_list(rows) do
    assigns = nil
    ~L"""
      <div class="row">
        <h3>Results</h3>
        <%= generate_download_button(columns, rows) %>
      </div>
      <table>
        <%= generate_headers_row(columns) %>
        <%= generate_result_rows(rows) %>
      </table>
    """
  end

  defp generate_results_table({nil, nil}) do
    assigns = nil
    ~L"""
      <h3>No results</h3>
    """
  end

  defp generate_results_table(_) do
    assigns = nil
    ~L"""
      <h3>Results</h3>
      <p>Something went wrong when rendering the results.</p>
    """
  end

  defp generate_download_button(columns, rows) do
    csv_content = CsvDownload.format_csv_for_download(columns, rows)
    assigns = nil

    ~L"""
      <%= if true do %>
        <a class="download-button" download="visualixir-query.csv" href="<%= csv_content %>" target="_blank">
          <svg style="width:24px;height:24px" viewBox="0 0 24 24">
            <path fill="#595454" d="M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z" />
          </svg>
        </a>
      <% end %>
    """
  end

  defp generate_error(error) do
    assigns = %{error: error}
    ~L"""
      <%= if true do %>
        <p class="sql-error">
          Error: <%= @error %>
        </p>
      <% end %>
    """
  end

  defp generate_headers_row(columns) do
    assigns = %{columns: columns}
    ~L"""
      <tr>
        <%= for column_name <- @columns do %>
          <th><%= column_name %></th>
        <% end %>
      </tr>
    """
  end

  defp generate_result_rows(rows) do
    assigns = %{rows: rows}
    ~L"""
    <%= for row <- @rows do %>
      <tr>
          <%= generate_single_row(row) %>
      </tr>
    <% end %>
    """
  end

  defp generate_single_row(row) do
    assigns = %{row: row}
    ~L"""
    <%= for field <- @row do %>
      <td><%= field %></td>
    <% end %>
    """
  end

  defp generate_tables_display([]) do
    nil
  end

  defp generate_tables_display(tables) do
    assigns = %{tables: tables}
    ~L"""
    <%= for {table, columns} <- @tables do %>
      <div>
        <h3 class="table-name"><%= table %></h3>
        <%= generate_columns_names(columns) %>
      </div>
    <% end %>
    """
  end

  defp generate_columns_names(columns) do
    assigns = %{columns: columns}
    ~L"""
    <%= for column <- @columns do %>
      <p class="no-vertical-margin small-text">
        <%= column %>
      </p>
    <% end %>
    """
  end
end
