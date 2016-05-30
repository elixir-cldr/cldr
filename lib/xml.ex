defmodule Xml do
  require Record
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement,   Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,      Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")
  @type xml_node :: {:xmlElement, list}
  @type xpath :: String.t
    
  @spec parse(String.t) :: xml_node | :error
  def parse(filename) when is_binary(filename) do
    {doc, _} = :xmerl_scan.file(String.to_charlist(filename))
    doc
  end
  
  @spec all(xml_node, xpath) :: [xml_node]
  def all(node, path) do
    for child_element <- xpath(node, path) do
      child_element
    end
  end

  @spec first(xml_node, xpath) :: xml_node | nil
  def first(node, path), do: node |> xpath(path) |> take_one
  defp take_one([head | _]), do: head
  defp take_one(_), do: nil

  @spec node_name(xml_node) :: String.t | nil
  def node_name(nil), do: nil
  def node_name(node), do: elem(node, 1)

  @spec attr(xml_node, String.t) :: String.t | nil
  def attr(node, name), do: node |> xpath("./@#{name}") |> extract_attr
  defp extract_attr([xmlAttribute(value: value)]), do: List.to_string(value)
  defp extract_attr(_), do: nil

  @spec text(xml_node) :: String.t | nil
  def text(node), do: node |> xpath("./text()") |> extract_text
  defp extract_text([xmlText(value: value)]), do: List.to_string(value)
  defp extract_text(_x), do: nil

  @spec xpath(xml_node, String.t) :: [xml_node]
  defp xpath(nil, _), do: []
  defp xpath(node, path) do
    :xmerl_xpath.string(to_char_list(path), node)
  end
  
end