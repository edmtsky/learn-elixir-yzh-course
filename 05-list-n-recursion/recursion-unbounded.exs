defmodule Recursion do
  @moduledoc """
  This module implements an example of Unbounded Recursion for traversing file
  system directories.

  alias Recursion, as: R
  path = "/tmp"
  R.browse(path)

  Here are two implementaions without depth limitation and with deep limitation
  The example is educational and does not include protection against looping
  possible due to symbolic links.
  """

  def browse(path) do
    browse(path, [])
  end

  defp browse(path, acc) do
    cond do
      File.regular?(path) ->
        [path | acc]

      File.dir?(path) ->
        {:ok, items} = File.ls(path)
        acc = browse_items(items, path, acc)
        [path | acc]

      true ->
        IO.puts("Not a file #{path}")
        acc
    end
  end

  defp browse_items([], _parent, acc), do: acc

  defp browse_items([item | items], parent, acc) do
    full_path = Path.join(parent, item)
    acc = browse(full_path, acc)
    browse_items(items, parent, acc)
  end

  #

  def browse_with_limit(path, limit) do
    acc = %{
      items: [],
      current_depth: 0,
      limit: limit
    }

    acc = do_browse_with_limit(path, acc)
    acc.items
  end

  defp do_browse_with_limit(
         _path,
         %{
           current_depth: limit,
           limit: limit
         } = acc
       ),
       do: acc

  defp do_browse_with_limit(path, acc) do
    items =
      cond do
        File.regular?(path) ->
          [path | acc.items]

        File.dir?(path) ->
          {:ok, childs} = File.ls(path)
          acc = %{acc | current_depth: acc.current_depth + 1}
          acc = do_browse_items(childs, path, acc)
          [path | acc.items]

        true ->
          IO.puts("Not a file #{path}")
          acc
      end

    %{acc | items: items}
  end

  defp do_browse_items([], _parent, acc), do: acc

  defp do_browse_items([item | items], parent, acc) do
    full_path = Path.join(parent, item)
    acc = do_browse_with_limit(full_path, acc)
    do_browse_items(items, parent, acc)
  end
end
