class AskUserTool < RubyLLM::Tool
  description "Asks the user a clarifying question and returns their answer. Use it when something is ambiguous " \
              "and a wrong guess would give the user a wrong result. Do not ask about things you can determine " \
              "yourself. Ask one clear, self-contained question at a time."

  parameter :question, description: "The question to show to the user"

  # The call stays pending until the user has answered in the UI, which pauses
  # the agent loop (see AgentRunJob, which records the question). Once the
  # answer exists the loop resumes and #execute hands it to the model.
  requires_approval { |tool_call| AgentQuestion.answered.exists?(tool_call_id: tool_call.id) ? true : nil }

  def initialize(run)
    @run = run
  end

  def execute(question:, tool_call:)
    { answer: @run.questions.find_by!(tool_call_id: tool_call.id).answer }
  end
end
