## Developing and maintaining ex_cldr

The `ex_cldr` library and its derivative packages are driven by data provided by the amazing [CLDR](https://cldr.unicode.org) project. Updates to CLDR are released twice a year which triggers the need to provision that data for `ex_cldr`.

`ex_cldr` operates on the json content generated from the CLDR xml data files. The remainder of this document describes the process by which CLDR data is generated and provisioned for `ex_cldr`.

> #### Not to developers {: .info}
>
> The notes in this document are only relevant if updating ex_cldr with new data from
> the CLDR project. For all other uses of `ex_cldr`, just clone the repo
> (--depth=1 is probably enough) and hack away.

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
export CLDR_REPO="$HOME/development/cldr_repo"
git clone https://github.com/unicode-org/cldr $CLDR_REPO
```

Of course the locale name of the CLDR repo can be any valid repo name however for the remainder of this document it is assumed it is referenced by the shell variable `$CLDR_REPO`.

#### Java compiler and Maven

A java compiler and the `maven` tool are requirements for generating the CLDR toolchain.

Java is pre-installed on MacOS so installation should not be required. At least java release 9.0 is required. `maven` is not installed by default on MacOS so the following may be required:

```bash
brew install maven
```

The [Maven configuration for CLDR](http://cldr.unicode.org/development/maven) illustrates the configuration requirements a summary of which is contained below.

#### Generate a GiHub token for Maven

We are going to create a token. A token is used like a password, and should be kept secret as one. You can revoke a token independently from all other tokens, so we will create a token specifically for this use.

1. Go to https://github.com/settings/tokens - you may need to login with a 2nd factor.

2. Generate a new token with the scope `read:packages` checked and make a note of the token which is required in the next step.

3. Modify or create `$HOME/.m2/settings.xml` file to add the `<server>` stanza into the `<servers>` section. Keep the id `githubicu` as it is.

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

 <servers>
  <server>
   <id>githubicu</id>
   <username>your github user id</username>
   <password>your access token</password>
  </server>

 </servers>
</settings>
```

#### Clone the ex_cldr repository

Clone the [ex_cldr](https://github.com/elixir-cldr/cldr) repository into a suitable directory.

```bash
export EX_CLDR="$HOME/Development/ex_cldr"
git clone https://github.com/elixir-cldr/cldr $EX_CLDR
```

### Updating Unicode CLDR repository

When a new version of CLDR is released, notification is typically given on the [Unicode blog](http://blog.unicode.org). For example, [this](http://blog.unicode.org/2020/04/unicode-locale-data-v37-released_23.html) is the introduction of CLDR 37.

Whenever a new release is created, the local repo needs to be updated. A simple `git pull` is all that is required.

```bash
cd $CLDR_REPO
git pull
```

### Generating the Unicode CLDR json data

CLDR data is primarily stored in a series of XML files. However `ex_cldr` operates on json data generated from these files.  This section describes how to generate that json data.

1. Export required environment variables

Data generation is done via the file `ldml2json` which makes some assumptions about shell variable names and directory locations. The staging directory is used used to store data after the first phase on expansion of CLDR and the production directory is the final location of the generated data.

```bash
export EX_CLDR=directory_where_you_cloned_ex_cldr
export CLDR_REPO=directory_where_you_cloned_unicode_cldr
export CLDR_STAGING=directory_where_staging_data_will_be_saved
export CLDR_PRODUCTION=directory_where_production_data_will_be_saved
```

2. Create the staging and production directories

Ensure the staging and production directories exist. `ldml2json` will exit if they do not exist.

```bash
mkdir $CLDR_STAGING
mkdir $CLDR_PRODUCTION
```

3. Review and update the contents of ldml2json

Review the settings of the first 20 lines of `ldml2json` to ensure the environment variables are set to match your development environment. The file is also defined to use `/bin/zsh`. Change this to the appropriate shell for your environment.

4. Download the up-to-date ISO currency database
```bash
mix cldr.download.iso_currency
```

5. Execute ldml2json
```bash
$CLDR_REPO/ldml2json
```

Execution will take quite a few minutes but there is output generated so you can be assured that data is being processed.

### Update ex_cldr content

With the CLDR content now generated an in place in the `$CLDR_PRODUCTION` directory we can now generate the consolidated content used in `ex_cldr`.

1. Update the repo
```bash
cd $EX_CLDR
git pull
```

2. After updating the repository, the locales need to be consolidated into the format used by `ex_cldr`
```bash
mix cldr.consolidate
```

3. Then regenerate the `language_tags.ebin` file by executing the following making sure to set the `DEV` shell variable which disables locale stale tests:
```bash
DEV=true mix cldr.generate_language_tags
```


