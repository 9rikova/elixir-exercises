defmodule Matrix do
  @moduledoc """
  Helpers for working with multidimensional lists
  """

  @type list_2d :: [[any()]]
  @type map_2d :: %{any() => %{any() => any()}}

  @doc """
  Converts a multidimensional list into a zero-indexed map.

  ## Example

      iex> list = [[1, 2, 3]]
      ...> Matrix.from_list(list)
      %{0 => %{0 => 1, 1 => 2, 2 => 3}}
  """
  @spec from_list(list_2d() | nil) :: map_2d()
  def from_list(nil), do: %{}
  def from_list(list) when is_list(list) do
    convert_list_to_map(list)
  end

  defp convert_list_to_map(list, map \\ %{}, index \\ 0)
  defp convert_list_to_map([], map, _index), do: map
  defp convert_list_to_map([h|t], map, index) do
    map = Map.put(map, index, convert_list_to_map(h))
    convert_list_to_map(t, map, index + 1)
  end
  defp convert_list_to_map(other, _, _), do: other

  @doc """
  Converts a zero-indexed map into a multidimensional list.

  ## Example

      iex> matrix = %{0 => %{0 => 1, 1 => 2, 2 => 3}}
      ...> Matrix.to_list(matrix)
      [[1, 2, 3]]
  """
  @spec to_list(map_2d() | nil) :: list_2d()
  def to_list(nil), do: []
  def to_list(matrix) when is_map(matrix) do
    convert_map_to_list(matrix)
  end

  defp convert_map_to_list(matrix) when is_map(matrix) do
    for {_index, value} <- matrix,
        into: [],
        do: convert_map_to_list(value)
  end
  defp convert_map_to_list(other), do: other
end
