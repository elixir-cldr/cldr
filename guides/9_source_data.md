# Source Data from CLDR

Data is from the ICU's CLDR project when is downloaded in XML format.  For ease of consumption it is then converted to `json` format and stored in the `/data` directory of the `ex_cldr` project which is typically in your project `/deps` directory.

## Downloading updates to CLDR

A `Mix` task, `cldr.download` is available for downloading the latest CLDR repository.  This task performs the following:

* Download the CLDR latest repository into the `/downloads` directory of `/deps/cldr`

* Adds `/downloads` to `.gitignore`

* `unzip`s the downloaded files

* Uses the downloaded java app `ldml2json` app to translate the xml files to json in the `/deps/cldr/data` directory

* Removes redundant `package.json` and `bower.json` files from the `/deps/cldr/data` directory

## Note

This `Mix` tasks is intended primarily for the use of the `Cldr` maintainer and not intended for general use.