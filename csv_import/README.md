# Cat imports

A small Rails app in which an AI agent (built with [RubyLLM](https://rubyllm.com)) turns whatever file
you upload into a list of cats.

## Running it

Requires Ruby 3.3.1+ (pinned to 3.3.8 in `.tool-versions`; Ruby 3.3.0 cannot parse RubyLLM 2.x).

```sh
bundle install
bin/rails db:prepare ruby_llm:load_models
ANTHROPIC_API_KEY=sk-ant-... bin/rails server
```

Open http://localhost:3000, drop a file and watch the agent work.

The agent uses `claude-opus-5-5` by default. Set `AGENT_MODEL` to any model RubyLLM knows
(with the matching `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` or `GEMINI_API_KEY`) to change it.

## How it works

- `CatImport` has many `Cat`s. The uploaded file is stored untouched in `storage/cat_imports/<env>/<id>/input`.
- `Cat::FIELDS` is the target structure: used by the agents, by the output validation and by the UI.
- An import also has `Breed`s (`Breed::FIELDS`), shown on the Breeds tab (`/imports/:id/breeds`). They come
  from a `BreedImport`: the user enters the URL of an API and an agent extracts the breeds from it.
- Every cat has a `breed_name`. When cats are imported, cats whose `breed_name` matches a breed of the same
  import (ignoring case) are linked to it through `breed_id`. Importing breeds does not link any cats, and it
  drops existing links because the breeds are replaced; use the Assign breeds tab afterwards.
- The Assign breeds tab (`/imports/:id/breed_assignments`) starts a `BreedAssignment`: an agent that links
  every cat to a breed, running whatever matching code it finds reasonable and asking the user about names it
  cannot match, until no cat is left without a breed.
- A completed import can have `Report`s: the user describes what they want and an agent builds a table
  (`columns` and `rows`, stored as JSON on the report).
- A completed import can also have `Chart`s: the user describes a visualization and an agent draws it as a
  PNG image.
- Imports, breed imports, breed assignments, reports and charts are all "agent runs" (`AgentRun` concern): status, persisted conversation
  (`Chat`/`Message`), questions to the user (`AgentQuestion`), activity log (`AgentEvent`) and a scratch directory.
- `CatImportAgent` (`app/agents`) has these tools (`app/tools`):
  - `describe_target_structure` – the columns the file has to be transformed into
  - `peek_file` – raw bytes of the upload (first 1024 by default)
  - `execute_ruby` – runs Ruby in a subprocess; input at `ENV["INPUT_FILE"]`, result goes to `ENV["OUTPUT_FILE"]`
  - `ask_user` – asks the user a question and waits for the answer
  - `finish_import` – validates the output file, loads it into `cats` and marks the import as completed
- `BreedImportAgent` has these tools:
  - `describe_target_structure` – how the breeds table is constructed
  - `execute_ruby` – as above, used to explore the API at `ENV["API_URL"]` and to extract the breeds
  - `ask_user`, `finish_import` – as above, loading into `breeds`
- `BreedAssignmentAgent` has these tools:
  - `export_cats_and_breeds` – exports the cats and breeds to temporary CSV files
  - `execute_ruby` – as above
  - `ask_user` – asks the user which breed to use for names it cannot match
  - `assign_breeds` – saves cat → breed assignments and returns the cats still without a breed; completes the
    run when none are left
- `ReportAgent` has these tools:
  - `export_data` – exports the import's cats and breeds to temporary CSV files and returns their paths
  - `execute_ruby` – as above; the report table goes to `ENV["OUTPUT_FILE"]`
  - `ask_user` – asks a clarifying question
  - `finish_report` – validates the output file, saves it as the report's table and marks the report as completed
- `ChartAgent` has these tools:
  - `export_data`, `execute_ruby`, `ask_user` – as for reports
  - `finish_chart` – validates the PNG at `ENV["OUTPUT_FILE"]` and saves it as the chart
  The agent draws an SVG in Ruby and converts it with `rsvg-convert`, which must be installed
  (`brew install librsvg`).
- `AgentRunJob` runs any of the agents. When the agent asks a question the job simply ends; answering in the
  UI enqueues the job again and the agent resumes.
- Script failures and errors while saving are returned to the agent so it can fix them.
- An agent gets at most 20 turns (model responses) per run (`ApplicationAgent::MAX_TURNS`); after that the
  run fails.
- Import and report pages update live over Turbo Streams.

## Security note

`execute_ruby` runs model-written code on the host. It gets a scratch working directory, a stripped
environment (no API keys) and a 60 second timeout, but it is **not sandboxed**: it can read and write
anything the Rails process can, and it has network access (the breeds import needs it), so it can reach
whatever the host can reach, including internal services. Run the app in a container or VM before feeding
it files or API URLs you do not trust.
