defmodule Cldr.Locale.DistanceTrie.Builder do
  @moduledoc false

  # Builds the distance trie from Cldr.Config.language_matching/0.
  # Kept in a separate module so the parent module can bake the
  # built trie into a module attribute at compile time.

  @doc false
  def build do
    data = Cldr.Config.language_matching()
    rules = Map.fetch!(data, :language_match)
    variables = Map.fetch!(data, :match_variables)

    {lang_rules, script_rules, territory_rules} = partition_rules(rules)

    trie = %{}
    trie = insert_language_rules(trie, lang_rules)
    trie = insert_script_rules(trie, script_rules)
    trie = insert_territory_rules(trie, territory_rules, variables)
    {trie, variables}
  end

  defp partition_rules(rules) do
    Enum.reduce(rules, {[], [], []}, fn rule, {lang, script, terr} ->
      case length(rule.desired) do
        1 -> {[rule | lang], script, terr}
        2 -> {lang, [rule | script], terr}
        3 -> {lang, script, [rule | terr]}
      end
    end)
    |> then(fn {l, s, t} -> {Enum.reverse(l), Enum.reverse(s), Enum.reverse(t)} end)
  end

  # ── Language level ─────────────────────────────────────────

  defp insert_language_rules(trie, rules) do
    Enum.reduce(rules, trie, fn rule, acc ->
      [desired_lang] = rule.desired
      [supported_lang] = rule.supported
      one_way = Map.get(rule, :one_way, false)
      distance = rule.distance

      acc = put_lang_entry(acc, desired_lang, supported_lang, distance)

      if not one_way do
        put_lang_entry(acc, supported_lang, desired_lang, distance)
      else
        acc
      end
    end)
  end

  defp put_lang_entry(trie, desired, supported, distance) do
    key = {desired, supported}
    Map.put_new(trie, key, %{distance: distance, script: %{}})
  end

  # ── Script level ───────────────────────────────────────────

  defp insert_script_rules(trie, rules) do
    Enum.reduce(rules, trie, fn rule, acc ->
      [desired_lang, desired_script] = rule.desired
      [supported_lang, supported_script] = rule.supported
      one_way = Map.get(rule, :one_way, false)
      distance = rule.distance

      acc =
        put_script_entry(
          acc,
          desired_lang,
          supported_lang,
          desired_script,
          supported_script,
          distance
        )

      if not one_way do
        put_script_entry(
          acc,
          supported_lang,
          desired_lang,
          supported_script,
          desired_script,
          distance
        )
      else
        acc
      end
    end)
  end

  defp put_script_entry(
         trie,
         desired_lang,
         supported_lang,
         desired_script,
         supported_script,
         distance
       ) do
    lang_key = {desired_lang, supported_lang}

    lang_node =
      Map.get(trie, lang_key) || Map.get(trie, {desired_lang, :*}) || %{distance: 0, script: %{}}

    script_key = {desired_script, supported_script}
    script_table = Map.get(lang_node, :script, %{})
    script_table = Map.put_new(script_table, script_key, %{distance: distance, territory: %{}})

    updated_node = Map.put(lang_node, :script, script_table)
    Map.put(trie, lang_key, updated_node)
  end

  # ── Territory level ────────────────────────────────────────

  defp insert_territory_rules(trie, rules, variables) do
    Enum.reduce(rules, trie, fn rule, acc ->
      [desired_lang, desired_script, desired_terr] = rule.desired
      [supported_lang, supported_script, supported_terr] = rule.supported
      one_way = Map.get(rule, :one_way, false)
      distance = rule.distance

      desired_keys = expand_territory_keys(desired_terr, variables)
      supported_keys = expand_territory_keys(supported_terr, variables)

      acc =
        for dk <- desired_keys, sk <- supported_keys, reduce: acc do
          acc ->
            put_territory_entry(
              acc,
              desired_lang,
              supported_lang,
              desired_script,
              supported_script,
              dk,
              sk,
              distance
            )
        end

      if not one_way do
        for dk <- supported_keys, sk <- desired_keys, reduce: acc do
          acc ->
            put_territory_entry(
              acc,
              supported_lang,
              desired_lang,
              supported_script,
              desired_script,
              dk,
              sk,
              distance
            )
        end
      else
        acc
      end
    end)
  end

  # Expand territory patterns to trie keys.
  # {:in, var} expands to individual territory atoms.
  # {:not_in, var} stays as-is (checked at lookup time).
  # :* stays as :*.
  defp expand_territory_keys(:*, _variables), do: [:*]
  defp expand_territory_keys({:in, variable}, variables), do: Map.fetch!(variables, variable)
  defp expand_territory_keys({:not_in, _variable} = not_in, _variables), do: [not_in]
  defp expand_territory_keys(territory, _variables) when is_atom(territory), do: [territory]

  defp put_territory_entry(
         trie,
         desired_lang,
         supported_lang,
         desired_script,
         supported_script,
         desired_terr,
         supported_terr,
         distance
       ) do
    lang_key = {desired_lang, supported_lang}

    lang_node =
      Map.get(trie, lang_key) || Map.get(trie, {desired_lang, :*}) ||
        %{distance: nil, script: %{}}

    script_key = {desired_script, supported_script}
    script_table = Map.get(lang_node, :script, %{})

    script_node =
      Map.get(script_table, script_key) || Map.get(script_table, {desired_script, :*}) ||
        %{distance: nil, territory: %{}}

    terr_key = {desired_terr, supported_terr}
    territory_table = Map.get(script_node, :territory, %{})
    territory_table = Map.put_new(territory_table, terr_key, distance)

    updated_script_node = Map.put(script_node, :territory, territory_table)
    updated_script_table = Map.put(script_table, script_key, updated_script_node)
    updated_lang_node = Map.put(lang_node, :script, updated_script_table)
    Map.put(trie, lang_key, updated_lang_node)
  end
end

defmodule Cldr.Locale.DistanceTrie do
  @moduledoc false

  # A 3-level nested map implementing the ICU XLocaleDistance trie
  # for locale distance lookups.
  #
  # The trie is keyed by {desired, supported} tuples at each level.
  # Wildcard entries use :* and negative variable entries use
  # {:not_in, variable} which are checked at lookup time.
  #
  # Built once at compile time from Cldr.Config.language_matching/0 and
  # held as a module attribute. There is no runtime build, no GenServer,
  # no :persistent_term — the data is fully static.

  @distance_trie Cldr.Locale.DistanceTrie.Builder.build()

  @doc false
  def trie, do: @distance_trie

  @spec lookup(String.t(), atom() | nil, atom() | nil, String.t(), atom() | nil, atom() | nil) ::
          number()
  def lookup(
        desired_lang,
        desired_script,
        desired_territory,
        supported_lang,
        supported_script,
        supported_territory
      ) do
    {trie, variables} = trie()
    default_lang_node = Map.get(trie, {:*, :*}) || %{distance: 0, script: %{}}

    # Language level
    {lang_distance, lang_node} =
      if desired_lang == supported_lang do
        node =
          cascade_lookup(trie, desired_lang, supported_lang) ||
            default_lang_node

        {0, node}
      else
        node =
          cascade_lookup(trie, desired_lang, supported_lang) ||
            default_lang_node

        distance = node[:distance] || default_lang_node.distance
        {distance, node}
      end

    # Script level — check lang_node's table, fall back to default
    script_table = lang_node[:script] || %{}
    default_script_table = default_lang_node[:script] || %{}

    {script_distance, script_node} =
      if desired_script == supported_script do
        node =
          cascade_lookup(script_table, desired_script, supported_script) ||
            cascade_lookup(default_script_table, desired_script, supported_script)

        {0, node}
      else
        node =
          cascade_lookup(script_table, desired_script, supported_script) ||
            cascade_lookup(default_script_table, desired_script, supported_script)

        cond do
          node && node[:distance] -> {node.distance, node}
          node -> {default_script_table[{:*, :*}][:distance] || 0, node}
          true -> {0, nil}
        end
      end

    # Territory level
    default_script_node =
      Map.get(script_table, {:*, :*}) ||
        Map.get(default_script_table, {:*, :*}) ||
        %{distance: 0, territory: %{}}

    territory_table = (script_node && script_node[:territory]) || %{}
    default_territory_table = default_script_node[:territory] || %{}

    territory_distance =
      if desired_territory == supported_territory do
        0
      else
        resolve_territory_distance(
          territory_table,
          default_territory_table,
          desired_territory,
          supported_territory,
          variables
        )
      end

    lang_distance + script_distance + territory_distance
  end

  defp resolve_territory_distance(territory_table, default_table, desired, supported, variables) do
    case territory_cascade_lookup(territory_table, desired, supported, variables) do
      nil ->
        case territory_cascade_lookup(default_table, desired, supported, variables) do
          nil -> 0
          distance -> distance
        end

      distance ->
        distance
    end
  end

  # Territory-level cascade with variable-aware matching.
  # Tries in order: exact → {desired, :*} → {:*, supported} → not_in rules → {:*, :*}
  defp territory_cascade_lookup(table, desired, supported, variables) do
    Map.get(table, {desired, supported}) ||
      Map.get(table, {desired, :*}) ||
      Map.get(table, {:*, supported}) ||
      find_not_in_match(table, desired, supported, variables) ||
      Map.get(table, {:*, :*})
  end

  # Check {:not_in, var} entries — both desired and supported must NOT be in the variable
  defp find_not_in_match(table, desired, supported, variables) do
    # Try concrete + not_in combinations first (more specific),
    # then not_in + not_in (less specific)
    find_not_in_concrete(table, desired, supported, variables) ||
      find_not_in_both(table, desired, supported, variables)
  end

  # One side is a concrete territory, the other is {:not_in, var}
  defp find_not_in_concrete(table, desired, supported, variables) do
    # Check {desired, {:not_in, var}} — desired is concrete, supported must not be in var
    result =
      Enum.find_value(table, fn
        {{^desired, {:not_in, var}}, distance} ->
          set = Map.fetch!(variables, var)
          if supported not in set, do: distance

        _ ->
          nil
      end)

    # Check {{:not_in, var}, supported} — supported is concrete, desired must not be in var
    result ||
      Enum.find_value(table, fn
        {{{:not_in, var}, ^supported}, distance} ->
          set = Map.fetch!(variables, var)
          if desired not in set, do: distance

        _ ->
          nil
      end)
  end

  # Both sides are {:not_in, var} or {:not_in, var} + :*
  defp find_not_in_both(table, desired, supported, variables) do
    Enum.find_value(table, fn
      {{{:not_in, var_d}, {:not_in, var_s}}, distance} ->
        desired_set = Map.fetch!(variables, var_d)
        supported_set = Map.fetch!(variables, var_s)

        if desired not in desired_set and supported not in supported_set do
          distance
        end

      {{{:not_in, var}, :*}, distance} ->
        set = Map.fetch!(variables, var)
        if desired not in set, do: distance

      {{:*, {:not_in, var}}, distance} ->
        set = Map.fetch!(variables, var)
        if supported not in set, do: distance

      _ ->
        nil
    end)
  end

  # Cascade lookup for language and script levels (no variable matching needed)
  defp cascade_lookup(table, desired, supported) do
    Map.get(table, {desired, supported}) ||
      Map.get(table, {desired, :*}) ||
      Map.get(table, {:*, supported}) ||
      Map.get(table, {:*, :*})
  end

end
