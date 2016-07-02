#@title Configuration

# Configuration

The basis of gitomate is that you configure how you want your system set up and gitomate tries to make it happen, much like a provisioning software. The configuration is declarative, so you can run gitomate as often as you want and it will inform you if anything has changed and try to rectify the situation, like a monitoring software.

The configuration is read from files. Currently gitomate cannot take configuration options directly from the command line, but if you must generate them on the fly you are advised to write a temporary file and tell gitomate to parse it.

The configuration is written in YAML. If you don't know YAML, go and look up the basic syntax. Gitomate does not use advanced YAML features. Basically you should know how to write arrays and objects (hashes in ruby). Hashes are the basis of the configuration system, as they are key -> value pairs. 

## Allowed types

All keys in the gitomate configuration should be ruby symbols, but they can be strings in which case they will be converted automatically to symbols. A symbol is written as `:key` where as a string is written as `'key'`. 

Values shouldn't be ruby objects. It should be standard types recognised by YAML although they can be symbols as well. For security reasons all ruby objects will be disregarded, so if you generate YAML from ruby code be sure to check for `!ruby/object:MyModule::MyClass`. Values can be Hashes, so this allows for a hierarchical configuration layout. String values do not need to be quoted in yaml, basically they run from the first non-whitespace char after the colon to the end of the line.

## Parsing order matters

Gitomate reads configuration files in the order in which they are given and it merges all hashes so directives given in later files override earlier ones. NOTE that Array values are not merged, but overridden. The notable places where gitomate expects Arrays in it's configuration are in the `include`, `repos` and `gitusers` sections, which means that if you define a number of repositories in one file and a later configuration file specifies others, the latter will replace the first, not merge with them.

## Telling gitomate which files to parse

A default configuration and an example file come with the installation. They are always read, and shouldn't be modified. They are overridden by your configuration files which you should put in /etc/gitomate.d/ Configuration files will only be parsed if they have the `.yml` extension and if they aren't hidden (.dotfiles). If you want gitomate to consider configuration files from other locations, you need to specify them on the command line with `--conf = "dir1" "file" "dir2"`. Files passed on the command line will override files from /etc/gitomate.d which will override the default configuration which comes with the installation. Gitomate will issue a warning but function correctly if /etc/gitomate.d does not exist.

You can pass either files or directories. In the latter case gitomate will glob for `**/*.yml`, ignoring hidden files and parse all files in alphabetical order. Note that subdirectory names have influence on the ordering. The `include` option on the top level of a file allows you to include further configuration files or directories. You don't need to put this at the end, the latter files will always be considered after and thus override the current file.

## Profiles

On the root of the configuration files can only exist 2 types of keys. The first is `include`. Anything else is considered a profile name. Profiles allow you to define different sets of configuration so you can specify these on the commandline with `--profile = maintainance` to put your server in a maintainance mode for example (maybe disable some websites, etc...). If no profile is specified, the `default` profile is used which is sufficient for most situations. Profiles can specify an `ìnherit:` key which allows you to inherit other profiles to override their options. Multiple inheritance is not supported. All profiles inherit from the default profile, and default does not inherit from any profile. It is the root. Circular dependencies will trigger an error and processing will be stopped. Profile inheritance is evaluated after all files are processed, so you can mix profile sections wherever you like.

## Configuration directives

For examples, please look at the conf directory in the installation directory as well as at the unit tests for gitomate. All options recognised by gitomate are in `default.yml` and are fully commented. You can override everything except for the `include`, since once files are parsed they won't be unloaded.
