%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "web/", "apps/"],
        excluded: ["lib/cldr/number/ordinal.ex", "lib/cldr/number/cardinal.ex"]
      }
    }
  ]
}