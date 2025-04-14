# mix escript.build

Builds an escript for the project.

An escript is an executable that can be invoked from the command line.
An escript can run on any machine that has Erlang/OTP installed and
by default does not require Elixir to be installed, as Elixir is embedded as
part of the escript.

This task guarantees the project and its dependencies are compiled and packages
them inside an escript. Before invoking `mix escript.build`, it is only necessary
to define a `:escript` key with a `:main_module` option in your mix.exs file:

```elixir
defmodule WorkReport.MixProject do
  use Mix.Project

  def project do
    [
    #...
        escript: [main_module: MyApp.CLI]
    ]
  end
    #....
end
```

Escripts should be used as a mechanism to share scripts between developers and
not as a deployment mechanism. For running live systems, consider using `mix run`
or building releases. See the Application module for more information on systems
life cycles.

All of the configuration defined in `config/config.exs` will be included as part
of the escript. config/runtime.exs is also included for Elixir escripts.
Once the configuration is loaded, this task starts the current application.
If this is not desired, set the `:app` configuration to nil.

This task also removes documentation and debugging chunks from the compiled .beam files to reduce the size of the escript. If this is not desired, check the :strip_beams option.
Command line options

Expects the same command line options as mix compile.
Configuration

The following option must be specified in your mix.exs under the :escript key:

    :main_module - the module to be invoked once the escript starts. The module must contain a function named main/1 that will receive the command line arguments. By default the arguments are given as a list of binaries, but if project is configured with language: :erlang it will be a list of charlists.

The remaining options can be specified to further customize the escript:

    :name - the name of the generated escript. Defaults to app name.

    :path - the path to write the escript to. Defaults to app name.

    :app - the app that starts with the escript. Defaults to app name. Set it to nil if no application should be started.

    :strip_beams - if true strips BEAM code in the escript to remove chunks unnecessary at runtime, such as debug information and documentation. Can be set to [keep: ["Docs", "Dbgi"]] to strip while keeping some chunks that would otherwise be stripped, like docs, and debug info, for instance. Defaults to true.

    :embed_elixir - if true embeds Elixir and its children apps (ex_unit, mix, and the like) mentioned in the :applications list inside the application/0 function in mix.exs.

    Defaults to true for Elixir projects, false for Erlang projects.

    Note: if you set this to false for an Elixir project, you will have to add paths to Elixir's ebin directories to ERL_LIBS environment variable when running the resulting escript, in order for the code loader to be able to find :elixir application and its children applications (if they are used).

    :shebang - shebang interpreter directive used to execute the escript. Defaults to "#! /usr/bin/env escript\n".

    :comment - comment line to follow shebang directive in the escript. Defaults to "".

    :emu_args - emulator arguments to embed in the escript file. Defaults to "".

    :include_priv_for - a list of application names (atoms) specifying applications which priv directory should be included in the resulting escript archive. Currently the expected way of accessing priv files in an escript is via :escript.extract/2. Defaults to [].

There is one project-level option that affects how the escript is generated:

    language: :elixir | :erlang - set it to :erlang for Erlang projects managed by Mix. Doing so will ensure Elixir is not embedded by default. Your app will still be started as part of escript loading, with the config used during build.

Example

In your mix.exs:

```elixir
defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.0.1",
      escript: escript()
    ]
  end

  def escript do
    [main_module: MyApp.CLI]
  end
end
```

Then define the entrypoint, such as the following in lib/cli.ex:

```elixir
defmodule MyApp.CLI do
  def main(_args) do
    IO.puts("Hello from MyApp!")
  end
end
```
