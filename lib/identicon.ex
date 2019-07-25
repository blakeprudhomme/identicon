defmodule Identicon do
  @moduledoc """
  An app for generating github style avatars for users without an image.
  """

  @doc """
  Generates an image based on a string input and saves the image to a file.

  ## Examples

      iex> Identicon.main("blake")
      :ok
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixil_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Receives a string input, converts it to a hash that is assigned to he hex key
  in the Image strcut.

  Returns Image strcut.

  ## Examples

      iex> Identicon.hash_input("blake")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [58, 164, 158, 198, 191, 201, 16, 100, 127, 161, 197, 160, 19, 228, 142,
        239],
        pixel_map: nil
      }

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Receives the Image struct, pulls off the first 3 numbers from the hex value
  and assigns them to the color key

  Returns Image strcut.

  ## Examples

      iex> image = Identicon.hash_input("blake")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
        color: {58, 164, 158},
        grid: nil,
        hex: [58, 164, 158, 198, 191, 201, 16, 100, 127, 161, 197, 160, 19, 228, 142, 239],
        pixel_map: nil
      }

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Receives a list of three elements and creates a new list with the first two
  elements appended to end in reverse order.

  Returns new list.

  ## Examples

      iex> list = [1, 2, 3]
      iex> Identicon.mirror_row(list)
      [1, 2, 3, 2, 1]

  """
  def mirror_row(row) do
    [first, second | _tails] = row

    row ++ [second, first]
  end

  @doc """
  Receives the Image struct, builds a list of tuples with each value in hex
  coupled with its index then assigns it the grid key.

  Returns Image strcut.

  ## Examples

      iex> image = Identicon.hash_input "blake"
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: nil,
        grid: [
          {58, 0},
          {164, 1},
          {158, 2},
          {164, 3},
          {58, 4},
          {198, 5},
          {191, 6},
          {201, 7},
          {191, 8},
          {198, 9},
          {16, 10},
          {100, 11},
          {127, 12},
          {100, 13},
          {16, 14},
          {161, 15},
          {197, 16},
          {160, 17},
          {197, 18},
          {161, 19},
          {19, 20},
          {228, 21},
          {142, 22},
          {228, 23},
          {19, 24}
        ],
        hex: [58, 164, 158, 198, 191, 201, 16, 100, 127, 161, 197, 160, 19, 228, 142, 239],
        pixel_map: nil
      }

  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Receives a Image struct, iderates over the values in the grid key building a
  new list with only the even values, then assigns it to the grid key.

  Returns Image strcut.

  ## Examples

      iex> image = Identicon.hash_input "blake"
      iex> image = Identicon.build_grid(image)
      iex> Identicon.filter_odd_squares(image)
      %Identicon.Image{
        color: nil,
        grid: [
          {58, 0},
          {164, 1},
          {158, 2},
          {164, 3},
          {58, 4},
          {198, 5},
          {198, 9},
          {16, 10},
          {100, 11},
          {100, 13},
          {16, 14},
          {160, 17},
          {228, 21},
          {142, 22},
          {228, 23}
        ],
        hex: [58, 164, 158, 198, 191, 201, 16, 100, 127, 161, 197, 160, 19, 228, 142,
        239],
        pixel_map: nil
      }

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter grid, fn({code, _index}) ->
        rem(code, 2) == 0
      end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Receives a Image struct, does some fancy math to determine grid points,
  then assigns them to the `pixel_map` key.

  Returns Image strcut.

  ## Examples

      iex> image = Identicon.hash_input "blake"
      iex> image = Identicon.build_grid(image)
      iex> image = Identicon.filter_odd_squares(image)
      iex> Identicon.build_pixil_map(image)
      %Identicon.Image{
        color: nil,
        grid: [
          {58, 0},
          {164, 1},
          {158, 2},
          {164, 3},
          {58, 4},
          {198, 5},
          {198, 9},
          {16, 10},
          {100, 11},
          {100, 13},
          {16, 14},
          {160, 17},
          {228, 21},
          {142, 22},
          {228, 23}
        ],
        hex: [58, 164, 158, 198, 191, 201, 16, 100, 127, 161, 197, 160, 19, 228, 142, 239],
        pixel_map: [
          {{0, 0}, {50, 50}},
          {{50, 0}, {100, 50}},
          {{100, 0}, {150, 50}},
          {{150, 0}, {200, 50}},
          {{200, 0}, {250, 50}},
          {{0, 50}, {50, 100}},
          {{200, 50}, {250, 100}},
          {{0, 100}, {50, 150}},
          {{50, 100}, {100, 150}},
          {{150, 100}, {200, 150}},
          {{200, 100}, {250, 150}},
          {{100, 150}, {150, 200}},
          {{50, 200}, {100, 250}},
          {{100, 200}, {150, 250}},
          {{150, 200}, {200, 250}}
        ]
      }

  """
  def build_pixil_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map grid, fn({_code, index}) ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  Saves the image to a file.

  Returns Image strcut.

  ## Examples

      iex> image = Identicon.hash_input("blake")
      iex> image = Identicon.pick_color(image)
      iex> image = Identicon.build_grid(image)
      iex> image = Identicon.filter_odd_squares(image)
      iex> image = Identicon.build_pixil_map(image)
      iex> image = Identicon.draw_image(image)
      iex> Identicon.save_image(image, "blake")
      :ok

  """
  def save_image(image, filename) do
    File.write("identicons/#{filename}.png", image)
  end
end
