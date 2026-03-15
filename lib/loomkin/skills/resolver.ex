defmodule Loomkin.Skills.Resolver do
  @moduledoc """
  Resolves available skills from disk, database, and the Jido registry.
  Returns Jido.AI.Skill.Spec structs for prompt injection.
  """

  import Ecto.Query

  alias Jido.AI.Skill.Registry, as: SkillRegistry
  alias Jido.AI.Skill.Spec
  alias Loomkin.Repo
  alias Loomkin.Schemas.Snippet
  alias Loomkin.Social

  @doc """
  Loads skills from the `.agents/skills` directory within `project_path`
  into the Jido registry.

  Returns `{:ok, count}` or `{:error, reason}`.
  """
  @spec load_from_disk(String.t()) :: {:ok, non_neg_integer()} | {:error, term()}
  def load_from_disk(project_path) do
    skills_path = Path.join(project_path, ".agents/skills")

    if File.dir?(skills_path) do
      SkillRegistry.load_from_paths([skills_path])
    else
      {:ok, 0}
    end
  end

  @doc """
  Loads skill snippets owned by `user` from the database and converts them
  to `%Spec{}` structs.

  Returns an empty list when `user` is `nil`.
  """
  @spec load_from_db(map() | nil) :: [Spec.t()]
  def load_from_db(nil), do: []

  def load_from_db(user) do
    user
    |> Social.list_user_snippets(type: :skill)
    |> Enum.map(&snippet_to_spec/1)
  end

  @doc """
  Returns all known skill specs by merging the Jido registry (disk-loaded)
  with DB-sourced specs for the given user.

  DB specs win on name conflicts, enabling user overrides of disk skills.
  """
  @spec list_manifests(String.t() | nil, map() | nil) :: [Spec.t()]
  def list_manifests(_project_path, user) do
    registry_specs = SkillRegistry.all()
    db_specs = load_from_db(user)

    db_names = MapSet.new(db_specs, & &1.name)

    deduped_registry =
      Enum.reject(registry_specs, fn spec -> MapSet.member?(db_names, spec.name) end)

    deduped_registry ++ db_specs
  end

  @doc """
  Retrieves the body text for a skill by name.

  Checks the Jido registry first, then falls back to a DB lookup against
  skill snippets whose frontmatter `name` field matches.

  Returns `{:ok, body_text}` or `{:error, :not_found}`.
  """
  @spec get_body(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def get_body(skill_name) do
    case SkillRegistry.lookup(skill_name) do
      {:ok, spec} ->
        extract_body(spec.body_ref)

      _ ->
        get_body_from_db(skill_name)
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp snippet_to_spec(snippet) do
    frontmatter = get_in(snippet.content, ["frontmatter"]) || %{}
    body = get_in(snippet.content, ["body"]) || ""

    name =
      Map.get(frontmatter, "name") ||
        Snippet.slugify(snippet.title)

    description =
      Map.get(frontmatter, "description") ||
        snippet.description ||
        ""

    raw_tools = Map.get(frontmatter, "allowed-tools")

    allowed_tools =
      raw_tools
      |> List.wrap()
      |> Enum.reject(&is_nil/1)

    %Spec{
      name: name,
      description: description,
      body_ref: {:inline, body},
      source: {:file, "db:#{snippet.id}"},
      tags: snippet.tags || [],
      allowed_tools: allowed_tools
    }
  end

  defp extract_body({:inline, text}), do: {:ok, text}
  defp extract_body({:file, path}), do: File.read(path)
  defp extract_body(nil), do: {:error, :not_found}

  defp get_body_from_db(skill_name) do
    result =
      from(s in Snippet,
        where: s.type == :skill,
        where: fragment("?->>'name' = ?", s.content["frontmatter"], ^skill_name),
        order_by: [desc: s.inserted_at],
        limit: 1
      )
      |> Repo.one()

    case result do
      %Snippet{} = snippet ->
        body = get_in(snippet.content, ["body"]) || ""
        {:ok, body}

      nil ->
        {:error, :not_found}
    end
  rescue
    _ -> {:error, :not_found}
  end
end
