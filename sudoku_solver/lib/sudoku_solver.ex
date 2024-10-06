defmodule SudokuSolver do
  @moduledoc """
  Documentation for SudokuSolver.
  """
  @coords 0..8

  @type map_sudoku :: %{integer() => %{integer() => integer()}}
  @type list_sudoku :: [[integer()]]

  @doc """
  Solve a given sudoku

  ## Parameters

  - `sudoku` (list or map): the sudoku to be solved
  - `format` (atom, optional): the format of output, it can be:
    - `:list` - returns the solved sudoku as list, default value
    - `:map` - returns the solved sudoku as a map
  - `method` (atom, optional): the solving method to use, it can be:
    - `:sync` - uses a synchronous approach to solve the sudoku, default value 
    - `:async` - uses a asynchronous approach to solve the sudoku, not recommended to use

  ## Examples

    iex(1)> sudoku = [
    ...(1)>   [0, 7, 0, 5, 8, 3, 0, 2, 0],
    ...(1)>   [0, 5, 9, 2, 0, 0, 3, 0, 0],
    ...(1)>   [3, 4, 0, 0, 0, 6, 5, 0, 7],
    ...(1)>   [7, 9, 5, 0, 0, 0, 6, 3, 2],
    ...(1)>   [0, 0, 3, 6, 9, 7, 1, 0, 0],
    ...(1)>   [6, 8, 0, 0, 0, 2, 7, 0, 0],
    ...(1)>   [9, 1, 4, 8, 3, 5, 0, 7, 6],
    ...(1)>   [0, 3, 0, 7, 0, 1, 4, 9, 5],
    ...(1)>   [5, 6, 7, 4, 2, 9, 0, 1, 3]
    ...(1)> ]
    iex(2)> SudokuSolver.solve(sudoku)
    [
      [1, 7, 6, 5, 8, 3, 9, 2, 4],
      [8, 5, 9, 2, 7, 4, 3, 6, 1],
      [3, 4, 2, 9, 1, 6, 5, 8, 7],
      [7, 9, 5, 1, 4, 8, 6, 3, 2],
      [4, 2, 3, 6, 9, 7, 1, 5, 8],
      [6, 8, 1, 3, 5, 2, 7, 4, 9],
      [9, 1, 4, 8, 3, 5, 2, 7, 6],
      [2, 3, 8, 7, 6, 1, 4, 9, 5],
      [5, 6, 7, 4, 2, 9, 8, 1, 3]
    ]
      
  """
  @spec solve(list_sudoku() | map_sudoku()) :: list_sudoku()
  @spec solve(list_sudoku() | map_sudoku(), atom(), atom()) :: list_sudoku() | map_sudoku()
  def solve(sudoku, format \\ :list, method \\ :sync)
  def solve(sudoku, format, method) when is_list(sudoku), do: solve(Matrix.from_list(sudoku), format, method)
  def solve(sudoku, format, method) when is_map(sudoku) do
    unless do_validate_sudoku(sudoku), do: raise(ArgumentError, message: "Invalid Sudoku")
    case {format, method} do
      {:list, :sync}  -> do_sync_solve(sudoku) |> Matrix.to_list()
      {:map, :sync}   -> do_sync_solve(sudoku)
      {:list, :async} -> do_async_solve(sudoku) |> Matrix.to_list()
      {:map, :async}  -> do_async_solve(sudoku)
    end
  end

  defp do_sync_solve(sudoku) do
    case do_find_empty_field(sudoku) do
      nil -> sudoku
      {row, col} -> 
        Enum.find_value(1..9, fn n ->
          if do_possible?(sudoku, row, col, n), do: do_sync_solve(put_in(sudoku[row][col], n))
        end)
    end
  end

  defp do_async_solve(sudoku) do
    case do_find_empty_field(sudoku) do
      nil -> sudoku
      {row, col} ->
        case do_find_possible_numbers(sudoku, row, col) do
          [] -> nil
          possible_numbers -> 
            Task.async_stream(possible_numbers, fn n -> do_async_solve(put_in(sudoku[row][col], n)) end)
            |> Enum.find_value(fn result -> elem(result, 1) end)
        end
    end
  end

  defp do_find_empty_field(sudoku) do
    Enum.find_value(@coords, fn row ->
      Enum.find_value(@coords, fn col ->
        if sudoku[row][col] == 0, do: {row, col}
      end)
    end)
  end

  defp do_find_possible_numbers(sudoku, row_coord, col_coord) do
    Enum.filter(1..9, &(do_possible?(sudoku, row_coord, col_coord, &1)))
  end

  defp do_possible?(sudoku, row_coord, col_coord, n) do
    row_valid = Enum.all?(@coords, fn col -> sudoku[row_coord][col] != n end)
    col_valid = Enum.all?(@coords, fn row -> sudoku[row][col_coord] != n end)

    square_row_start = div(row_coord, 3) * 3
    square_col_start = div(col_coord, 3) * 3

    square_valid = Enum.all?(square_row_start..(square_row_start + 2), fn row ->
      Enum.all?(square_col_start..(square_col_start + 2), fn col -> sudoku[row][col] != n end)
    end)

    row_valid && col_valid && square_valid
  end

  defp do_validate_sudoku(sudoku) do
    valid_row_size = Enum.all?(Map.values(sudoku), fn row -> is_map(row) && Enum.count(Map.keys(row)) == 9 end)
    valid_col_size = (sudoku |> Map.keys() |> Enum.count()) == 9
    
    valid_values = 
      Enum.all?(@coords, fn row ->
        Enum.all?(@coords, fn col ->
          num = sudoku[row][col]
          (num in 0..9) && (num == 0 || do_possible?(put_in(sudoku[row][col], 0), row, col, num))
        end)
      end)

    valid_row_size && valid_col_size && valid_values
  end
end
