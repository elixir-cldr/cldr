## Developing and maintaining ex_cldr

The `ex_cldr` library and its derivative packages are driven by data provided by the amazing [CLDR](https://cldr.unicode.org) project. Updates to CLDR are released twice a year which triggers the need to provision that data for `ex_cldr`.

`ex_cldr` operates on the json content generated from the CLDR xml data files. The remainder of this document describes the process by which CLDR data is generated and provisioned for `ex_cldr`.

### Initial setup

Installation instructions are platform dependent. For a typical MacOS environment the following using [Homebrew](https://brew.sh) will suffice.

1. Install git-lfs

`git-lfs` MUST be installed prior to cloning the repo since there are several large objects references from the repo.

```bash
brew install git-lfs
git lfs install
```

2. Clone the CLDR repo

Prior to any development work the [CLDR repository](https://github.com/unicode-org/cldr) should be cloned to the same development machine upon which `ex_cldr` development is to take place.

NOTE that `git-lfs` MUST be installed prior to cloning the repo.

```bash
# Set to whatever directory is appropriate
export $CLDR_REPO="$HOME/development/cldr_repo"
git clone https://github.com/unicode-org/cldr $CLDR_REPO
```

Of course the locale name of the CLDR repo can be any valid repo name however for the remainder of this document it is assumed it is referenced by the shell variable `$CLDR_REPO`.

#### Java compiler and ANT

A java compiler and the ANT tool are requirements for generating the CLDR toolchain.

Java is pre-installed on MacOS so installation should not be required. `ant` is not installed by default so the following is required:

```bash
brew install ant
```

#### Clone the ex_cldr repository

Clone the [ex_cldr](https://github.com/elixir-cldr/cldr) repository into a suitable directory.

```bash
export EX_CLDR="$HOME/Development/ex_cldr"
git clone https://github.com/elixir-cldr/cldr $EX_CLDR
```

### Updating CLDR content

When a new version of CLDR is released, notification is typically given on the [Unicode blog](http://blog.unicode.org). For example, [this](http://blog.unicode.org/2020/04/unicode-locale-data-v37-released_23.html) is the introduction of CLDR 37.

Whenever a new release is created, the local repo needs to be updated. A simple `git pull` is all that is required.

```bash
cd cldr_repo
git pull
```

### Generating the CLDR utilities

CLDR data is primarily stored in a series of XML files. However `ex_cldr` operates on json data generated from these files.  This section describes how to generate that json data.

1. Create the staging and production directories

Data generation is done via the file `ldml2json` which makes some assumptions about shell variable and directory locations. The staging directory is used used to store data after the first phase on expansion of CLDR and the production directory is the final location of the generated data.

```bash
mkdir $HOME/development/cldr_staging_data
mkdir $HOME/development/cldr_production_data
```

2. Export required environment variables

The `ldml2json` script requires four environment variables to be set.

```bash
export EX_CLDR directory_where_you_cloned_ex_cldr
export CLDR_REPO directory_where_you_cloned_unicode_cldr
export CLDR_STAGING directory_you_created_for_staging
export CLDR_PRODUCTION directory_you_created_for_production
```

3. Review and update the contents of ldml2json

Review the settings of the first 20 lines of `ldml2json` to ensure the environment variables are set to match your development environment. The file is also defined to use `/bin/zsh`. Change this to the appropriate shell for your environment.

4. Copy ldml2json into a directory in your path

To make it easy to execute, copy the `ldml2json` file into any directory that is in your `$PATH`. Make sure the execution flag is set.
```bash
chmod u+x $EX_CLDR/ldml2json
cp $EX_CLDR/ldml2json /some/directory/in/path
```

5. Download the up-to-date ISO currency database
```bash
mix cldr.download.iso_currency
```

6. Execute ldml2json

```bash
ldml2json
```

Execution will take quite a few minutes but there is output generated so you can be assured that data is being processed.

### Update ex_cldr content

With the CLDR content now generated an in place in the `$CLDR_PRODUCTION` directory we can now generate the consolidated content used in `ex_cldr`.

1. Update the repo
```bash
cd $EX_CLDR
git pull
```

2. After updating the respository, the locales need to be consolidated into the format used by `ex_cldr`.  This is done by:
```bash
mix cldr.consolidate
```

3. Then regenerate the `language_tags.ebin` file by executing the following. This task will run with `MIX_ENV=test` to ensure all available locales are generated.
```bash
mix cldr.generate_language_tags
```


