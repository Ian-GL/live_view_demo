defmodule LiveViewDemo.Charts.BarChartCalculations do

  # bar-width
  @chart_view_width 200
  @chart_view_height 100
  @y_offset 10
  @x_offset 30

  def generate_chart_data(query_result) do
    elem_count = length(query_result)

    column_width = @chart_view_width / ((elem_count * 2) + 2)
    greatest_y = get_greatest_y(query_result)
    y_factor = (1 * @chart_view_height) / greatest_y

    chart_data =
      query_result
      |> Enum.map_reduce(@x_offset, fn (e, acc_width) -> format_bar_data(e, column_width, y_factor, acc_width) end)
      |> elem(0)

    {chart_data, greatest_y}
  end

  defp get_greatest_y(query_result) do
    Enum.reduce(
      query_result,
      0,
      fn ({_, y}, acc) -> if y > acc, do: y, else: acc end
    )
  end

  defp format_bar_data({x_data, y_data}, column_width, y_factor, acc_width) do
    x_position = acc_width + column_width
    y_position = @chart_view_height - (y_factor * y_data)
    height = (@chart_view_height - y_position) - @y_offset

    data = %{
      x_label: x_data,
      y_label: y_data,
      x_position: x_position,
      y_position: y_position,
      width: column_width,
      height: height
    }
    # |> IO.inspect()

    {data, x_position + column_width}
  end

end
