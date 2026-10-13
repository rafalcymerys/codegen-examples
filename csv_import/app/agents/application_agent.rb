class ApplicationAgent < RubyLLM::Agent
  # How many responses the model may give per run, across pauses for user questions.
  MAX_TURNS = 20

  chat_model Chat
  model ENV["AGENT_MODEL"] || ENV["IMPORT_AGENT_MODEL"] || "claude-haiku-5-5"
end
