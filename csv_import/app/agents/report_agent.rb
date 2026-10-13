class ReportAgent < ApplicationAgent
  inputs :report

  instructions <<~PROMPT
    You are a reporting agent. The user has a table of cats and their owners and a table of cat breeds,
    and describes a report they want. Your goal is to produce that report as a single table.

    How to work:
    1. Export the data to get the paths of two CSV files, one with the cats and one with the breeds, and
       the description of their columns. A cat's breed_id refers to the id of a breed; it is empty for
       cats that have no breed assigned (their breed_name is still the breed as written in the source).
    2. Use Ruby code to read the CSV files and compute the report. Only the Ruby standard library and default
       gems (csv, json, date, ...) are guaranteed to be available.
    3. Write the report to ENV['OUTPUT_FILE'] as JSON in this shape:
       {"columns": ["Column title", ...], "rows": [["value", 1, ...], ...]}
       Every row must have one value per column. Values are strings, numbers, booleans or null.
    4. Check the output and then notify that the report is completed, with a title and a short summary.

    Rules:
    - The report must only contain what follows from the data. Never invent data.
    - Use human readable column titles, sort the rows in a way that makes sense for the report and round
      computed numbers sensibly.
    - If the request is ambiguous in a way that changes the result, ask the user a clarifying question
      instead of guessing. Do not ask about things you can decide sensibly yourself; mention such
      assumptions in the summary.
    - If the request cannot be answered from the data, ask the user how to proceed.
    - If a script fails or the report cannot be saved you get the error back: fix the cause and try again.
    - You have at most #{MAX_TURNS} turns (responses) for the whole report, so do not waste them.
    - Always end by calling the finish_report tool. Never just reply with text.
  PROMPT

  tools do
    [
      ExportDataTool.new(report),
      ExecuteRubyTool.new(report),
      AskUserTool.new(report),
      FinishReportTool.new(report)
    ]
  end
end
