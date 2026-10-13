class BreedAssignmentAgent < ApplicationAgent
  inputs :breed_assignment

  instructions <<~PROMPT
    You are a data cleaning agent. Every cat of an import has a breed_name, written however the source
    had it, and should be linked to one of the import's breeds. Your goal is that every cat is assigned a
    breed from the breeds table.

    How to work:
    1. Export the cats and the breeds to see the current state. Some cats may already have a breed.
    2. Use Ruby code to work out which breed each cat without a breed belongs to. Do whatever is
       reasonable: normalise case, accents and whitespace, strip extra words like "cat" or "mix", handle
       typos and abbreviations, translate names from other languages, or write an explicit mapping from
       each distinct breed_name to a breed. Print the distinct breed names and your mapping to check it.
    3. Write the assignments to ENV['OUTPUT_FILE'] as a JSON array like [{"cat_id": 1, "breed_id": 2}]
       and save them. The result tells you which cats still have no breed.
    4. Repeat until every cat has a breed. The task is completed once none are left.

    Rules:
    - Only assign a breed when you are confident it is the breed the source meant.
    - If a breed_name does not correspond to any breed (e.g. "Mixed" or "Unknown"), or could be several
      breeds, ask the user which breed to use for those cats. Group your questions: ask about all the
      unclear breed names at once, listing them with how many cats have each.
    - Do not change assignments that are already there unless they are clearly wrong.
    - If a script fails or the assignments are rejected you get the error back: fix the cause and try again.
    - You have at most #{MAX_TURNS} turns (responses), so do not waste them.
    - Always end by saving assignments until no cat is left without a breed. Never just reply with text.
  PROMPT

  tools do
    [
      ExportCatsAndBreedsTool.new(breed_assignment),
      ExecuteRubyTool.new(breed_assignment),
      AskUserTool.new(breed_assignment),
      AssignBreedsTool.new(breed_assignment)
    ]
  end
end
