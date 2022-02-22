# Commanded Toolkit

There is currently only one "tool" in this repo. The Aggregate Inspector.

`threequarterspi` over on Slack asked if anyone had implemented some sort of time-traveling for `Commanded`. 

I immediately thought of the `redux devtools` and thought that would be pretty cool for viewing aggregate state over time...with real data.

So I set out to get a bit of something working. 

After discovering and digging a bit into [ratatouille](https://github.com/ndreynolds/ratatouille), I was able to get that little something.



https://user-images.githubusercontent.com/364786/155046788-26fd4ddf-b79c-4da1-81cf-b1347583d464.mp4

## Usage


Add `{:commanded_toolkit, github: "elixir-cqrs/commanded_toolkit", runtime: false, only: :dev}` to your deps and run `mix deps.get`.

You can launch the UI with `mix commanded.inspect.aggregate`. 

That can be a drag to type all the time, so I would recommend assigning an alias in your mix file.

```elixir
  def aliases do
    [
      view_state: "commanded.inspect.aggregate"
    ]
  end
```

and make sure you're including aliases in your project function.

```elixir
  def project do
    [
      ...
      deps: deps(),
      aliases: aliases(),
      ...
    ]
  end
```

Now you can just run `mix view_state`


### Navigation 

You can use the <kbd>⬆</kbd> / <kbd>⬇</kbd> or <kbd>j</kbd> / <kbd>k</kbd> keys to navigate through the history of your aggregate.

### Exiting

Strike <kbd>Ctrl+c</kbd> with some heft.

## notes

* The event store module you enter *must* be a valid EventStore.

* The aggregate module you enter *must* be a valid aggregate module with an `apply/2` function.

* The stream must exist. Duh

* The next time you run the mix task, it will present you with your last answers as defaults.

