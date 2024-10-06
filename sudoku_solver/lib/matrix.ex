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
    do_from_list(list)
  end

  defp do_from_list(list, map \\ %{}, index \\ 0)
  defp do_from_list([], map, _index), do: map
  defp do_from_list([h|t], map, index) do
    map = Map.put(map, index, do_from_list(h))
    do_from_list(t, map, index + 1)
  end
  defp do_from_list(other, _, _), do: other

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
    do_to_list(matrix)
  end

  defp do_to_list(matrix) when is_map(matrix) do
    for {_index, value} <- matrix,
        into: [],
        do: do_to_list(value)
  end
  defp do_to_list(other), do: other
end
