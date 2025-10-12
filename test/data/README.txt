This directory contains test data extracted from CLDR. Some of this data is used
for testing in `ex_cldr`. Other files are used by dependent libraries. The data is
kept here so there is only a single source of knowledge about the CLDR repo that is
required.

The shell script ldml.json is used to generate the JSON used by ex_cldr and it also
copies the test files into this location.