defmodule LiveViewDemoWeb.Examples do
  use Phoenix.LiveView

  alias LiveViewDemo.Queries.{UserQueries, OrderQueries}
  alias LiveViewDemo.Charts.{PieChartCalculations, BarChartCalculations}

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems avoid-header">
      <div>
        <h2>You can start building a chart by selecting the type<h2>
      </div>
      <div>
        <svg
          viewBox="0 0 200 110"
          style="margin-top: 50px;"
          height="300"
          width="450"
        >
          <line stroke="#595454" x1="30" x2="30" y2="90"></line>
          <line stroke="#595454" y1="90" y2="90" x1="30" x2="200"></line>
          <%= generate_y_ticks(@bar_highest_value) %>
          <%= generate_chart_bars(@bar_chart_data) %>
        </svg>
      </div>
      <div>
      </div>
      <div>
        <svg
          viewBox="-100 -100 200 200"
          style="margin-top: 50px;"
          height="250"
          width="250"
        >
          <%= generate_chart_slices(@pie_chart_data) %>
        </svg>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, put_charts_data(socket)}
  end

  defp put_charts_data(socket) do
    socket
    |> put_pie_chart_data()
    |> put_user_orders_chart_data()
  end

  defp put_pie_chart_data(socket) do
    chart_data =
      OrderQueries.get_orders_status_count()
      |> PieChartCalculations.generate_chart_data()

    assign(socket, pie_chart_data: chart_data)
  end

  defp put_user_orders_chart_data(socket) do
    {chart_data, greatest_y} =
      UserQueries.get_users_w_most_orders()
      |> BarChartCalculations.generate_chart_data()

    assign(socket, bar_chart_data: chart_data, bar_highest_value: greatest_y)
  end

  # def generate_chart(chart_data) do
  #
  # end

  def generate_chart_bars(chart_data) do
    assigns = %{chart_data: chart_data}

    ~L"""
      <%= for bar <- @chart_data do %>
        <g>
          <rect
            x="<%= bar.x_position %>"
            y="<%= bar.y_position %>"
            width="<%= bar.width %>"
            height="<%= bar.height %>"
            fill="#53a2f2">
          </rect>
          <text
            text-anchor="start"
            x="<%= 94 %>"
            y="<%= -(bar.x_position + 5) %>"
            fill="#000000"
            font-size="6"
            style="transform: rotate(0.25turn)"
          >
          <%= bar.x_label %>
          </text>
        </g>
      <% end %>
    """
  end

  def generate_y_ticks(highest_value) do
    value_step_inc = highest_value / 5
    space_between_ticks = 90 / 5
    ticks_position =
      1..5
      |> Enum.map(
        fn x ->
          {90 - (x * space_between_ticks), (x * value_step_inc) |> trunc()}
        end
        )
      |> IO.inspect()

    assigns = %{ticks_position: ticks_position}
    ~L"""
      <line stroke="#595454" x1="27" x2="30" y1="90" y2="90"></line>
      <text
        text-anchor="end"
        x="25"
        y="92"
        fill="#000000"
        font-size="6"
      >
        0
      </text>
      <%= for {tick, value} <- @ticks_position do %>
        <g>
          <line stroke="#595454" x1="27" x2="30" y1="<%= tick %>" y2="<%= tick %>">
          </line>
          <text
            text-anchor="end"
            x="25"
            y="<%= tick + 2 %>"
            fill="#000000"
            font-size="5"
          >
            <%= value %>
          </text>
        <g>
      <% end %>
    """
  end

  def generate_chart_slices(chart_data) do
    assigns = %{chart_data: chart_data}

    ~L"""
      <%= for slice <- @chart_data do %>
        <g>
          <path fill="<%= slice.fill_color %>" d="<%= slice.path_data %>"></path>
          <%= generate_slice_label(slice) %>
        </g>
      <% end %>
    """
  end

  def generate_slice_label(%{show_label: false}), do: nil

  def generate_slice_label(slice) do
    assigns = %{slice: slice}

    {text_x, text_y} = slice.text_coords

    percentage_text = "#{slice.percentage * 100 |> trunc() }%"

    ~L"""
      <text
        text-anchor="start"
        x="<%= text_x %>"
        y="<%= text_y %>"
        fill="#ffffff"
        font-size="10"
      >
        <%= slice.label %>
        <tspan dy="10" dx="-27">
          <%= percentage_text %>
        </tspan>
      </text>
    """
  end

  defp put_user_list(socket) do
    users = UserQueries.get_newest_users(10)

    assign(socket, users: users)
  end

  defp generate_users_table([]) do
    assigns = nil
    ~L"""
      <p>Sorry, no users yet</p>
    """
  end

  defp generate_users_table(users) do
    assigns = %{users: users}
    ~L"""
      <div>
        <%= for user <- @users do %>
          <div>
            <%= generate_user_row(user) %>
          </div>
        <% end %>
      </div>
    """
  end

  defp generate_user_row(user) do
    assigns = %{user: user}
    ~L"""
      <div class="row table-row space-around">
        <div>
          <%= user.first_name %>
        </div>
        <div>
          <%= user.last_name %>
        </div>
        <div>
          <%= user.email %>
        </div>
      </div>
    """
  end
end
