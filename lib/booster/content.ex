defmodule Booster.Content do
  @moduledoc """
  Content Cachex warmer to convert markdown (Obsidian notes) into HTML static content and populate articles cache.
  The generated content then is used to display as static content web pages.
  """

  use Cachex.Warmer

  require Logger

  @cache :content_cache
  @menu_id :content_menus

  @doc """
  Get content data
  """
  @spec get_data(String.t()) :: {:ok, Keyword.t() | nil}
  def get_data(id) do
    Cachex.get(@cache, id)
  end

  @doc """
  Get menu for content data.
  """
  @spec get_menu() :: {:ok, map()}
  def get_menu() do
    Cachex.get(@cache, @menu_id)
  end

  @doc """
  Merges two content objects into one, second taking precedence over first.
  """
  @spec merge(Keyword.t(), Keyword.t()) :: Keyword.t()
  def merge(first, second) do
    fmap = Enum.into(first, %{})
    smap = Enum.into(second, %{})
    # Do the merge
    smap
    |> Map.merge(fmap)
    |> Map.to_list()
  end

  @doc """
  Execute on cachex warmer to populate the cache.
  """
  @spec execute({String.t(), content_dir :: String.t()}) ::
          {:ok, [{String.t(), data :: any()}]} | :ignore
  def execute({page_domain, content_dir}) do
    # Return key value pairs to pooulate the content cache
    case File.ls(content_dir) do
      {:error, err} ->
        Logger.error("Content cache missing required dir: #{content_dir} - #{err}")
        :ignore

      {:ok, _} ->
        content_data = read(content_dir, page_domain)
        Logger.warning("Content cache updated")
        {:ok, content_data}
    end
  end

  ###
  defp read(content_dir, page_domain) do
    # Valid content directories should have index.md file -
    # it should contain needed metadata in yaml format.
    # All md files are compatible with Obsidian metadata.
    md_files = Path.wildcard("#{content_dir}/**/*.md")
    content_data = read_content(page_domain, md_files, %{})
    menus = construct_menus(content_data, %{})
    objects = [{@menu_id, menus} | content_data]
    Logger.info("Content read complete: #{inspect(objects)}")
    # Return list for cache
    objects
  end

  defp construct_menus([], menus), do: menus

  defp construct_menus(
         [{content_id, data} | rest],
         menus
       ) do
    case Keyword.get(data, :page_menu, nil) do
      nil ->
        # Do not put this into menu, if not defined page_menu
        construct_menus(rest, menus)

      menu_position ->
        name = Keyword.get(data, :page_menu_text, "NOT SET")
        href = Keyword.get(data, :page_path, "/")
        existing = Map.get(menus, menu_position, [])
        menu_item = %{name: name, href: href, content_id: content_id}
        construct_menus(rest, Map.put(menus, menu_position, [menu_item | existing]))
    end
  end

  defp construct_menus([_ignore | rest], menus), do: construct_menus(rest, menus)

  defp read_content(_domain, [], objects) do
    objects
    |> Map.to_list()
    |> Enum.map(fn {key, map} -> {key, keys_to_atoms(map)} end)
  end

  defp read_content(domain, [md_file | rest], objects) do
    case read_md(md_file) do
      %{"page_path" => path, "page_domain" => ^domain, "html" => new_html} = new_obj ->
        # Get content object by it's id
        content_id = "#{domain}#{path}"
        # Get page_id
        page_id = Map.get(new_obj, "page_id", "index")
        # Get previous object for the same content_id, with defaults
        %{"html" => prev_html} = prev_obj = Map.get(objects, content_id, %{"html" => %{}})
        # Update html object
        html = Map.put(prev_html, page_id, new_html)
        # Create updated content_object for given content_id
        content_obj =
          new_obj
          |> Map.replace("html", html)
          |> (&Map.merge(prev_obj, &1)).()

        # Continue
        read_content(domain, rest, Map.put(objects, content_id, content_obj))

      ignore ->
        Logger.debug("Content ignore (#{domain}) content: #{inspect(ignore)}")
        read_content(domain, rest, objects)
    end
  end

  defp keys_to_atoms(%{} = map) do
    Enum.map(map, fn {key, val} -> {String.to_atom(key), val} end)
  end

  defp read_md(md_file_path) do
    {:ok, md_content} = File.read(md_file_path)

    Logger.debug("Content read file #{md_file_path}, with: #{md_content}")

    md_opts = %Earmark.Options{
      code_class_prefix: "language-"
    }

    with [_, yaml, markdown] <- String.split(md_content, "---", parts: 3),
         {:ok, meta} <- YamlElixir.read_from_string(String.trim(yaml), atoms: true) do
      html =
        markdown
        |> String.trim()
        |> Earmark.as_html!(md_opts)
        |> HtmlSanitizeEx.html5()

      Map.put(meta, "html", html)
    else
      _ -> %{}
    end
  end
end
