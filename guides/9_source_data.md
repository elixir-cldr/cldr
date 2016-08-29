# Source Data from CLDR

What is the source data
where does it come from
how is it processed
how do you upgrade

## Source Data

Data is from the ICU's CLDR project when is downloaded in XML format.  For ease of consumption it is then converted to `json` format with the following commands:

```bash
java -DCLDR_DIR=. -jar tools/java/cldr.jar ldml2json -t main -p true -r true
java -DCLDR_DIR=. -jar tools/java/cldr.jar ldml2json -t supplemental -p true -r true
```
## Compilation

A lot of functions are generated during the compilation phase.  If all 511 locales are configured (an unlikely production use case) then compilation can take several minutes.  This is most typically when running `cldr` tests.
