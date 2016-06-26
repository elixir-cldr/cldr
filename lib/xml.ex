defmodule Xml do
  require Record
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement,   Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,      Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")
  @type document :: {:xmlElement, list}
  @type xpath :: String.t
    
  @spec parse(String.t) :: document | :error
  def parse(filename) when is_binary(filename) do
    {doc, _} = :xmerl_scan.file(String.to_charlist(filename))
    doc
  end
  
  @spec all(document, xpath) :: [document]
  def all(node, path) do
    for child_element <- xpath(node, path) do
      child_element
    end
  end

  @spec first(document, xpath) :: document | nil
  def first(node, path), do: node |> xpath(path) |> take_one
  defp take_one([head | _]), do: head
  defp take_one(_), do: nil

  @spec node_name(document) :: String.t | nil
  def node_name(nil), do: nil
  def node_name(node), do: elem(node, 1)

  @spec attr(document, String.t) :: String.t | nil
  def attr(node, name), do: node |> xpath("./@#{name}") |> extract_attr
  defp extract_attr([xmlAttribute(value: value)]), do: List.to_string(value)
  defp extract_attr(_), do: nil

  @spec text(document) :: String.t | nil
  def text(node), do: node |> xpath("./text()") |> extract_text
  defp extract_text([xmlText(value: value)]), do: List.to_string(value)
  defp extract_text(_x), do: nil

  @spec xpath(document, String.t) :: [document]
  defp xpath(nil, _), do: []
  defp xpath(node, path) do
    :xmerl_xpath.string(to_char_list(path), node)
  end
  
end