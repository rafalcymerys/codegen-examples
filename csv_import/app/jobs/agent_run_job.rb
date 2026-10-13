# Runs the agent of an import or a report until it finishes or needs the user.
# The conversation is persisted, so the job is simply enqueued again once the
# user has answered.
class AgentRunJob < ApplicationJob
  class TurnLimitReached < StandardError; end

  MAX_NUDGES = 2
  NUDGE = "You replied with text, which the user cannot see. Continue working and call the tool that finishes " \
          "the task when the output is ready, or call ask_user if you need information from the user."

  queue_as :default

  def perform(run)
    return if run.completed?

    run.transition_to!(:processing, error_message: nil)
    chat = find_or_create_chat(run)

    if chat.messages.where(role: "user").none?
      run.log("info", "Agent started working")
      chat.ask_later(run.kickoff_message)
    end
    advance(run, chat)

    MAX_NUDGES.times do
      break if chat.waiting? || run.completed?
      chat.ask_later(NUDGE)
      advance(run, chat)
    end

    settle(run, chat)
  rescue TurnLimitReached
    fail_run(run, "The agent used all #{run.agent_class::MAX_TURNS} turns without finishing.")
  rescue => e
    Rails.logger.error("[AgentRunJob] #{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}")
    fail_run(run, "#{e.class}: #{e.message}")
  end

  private

  def find_or_create_chat(run)
    return run.agent_class.find(run.chat_id, **run.agent_inputs) if run.chat_id

    run.agent_class.create!(**run.agent_inputs).tap { |chat| run.update!(chat:) }
  end

  # The agent loop: run the tools the model asked for, then let the model
  # respond again, for at most MAX_TURNS responses per run. Tools requested in
  # the last allowed turn still run.
  def advance(run, chat)
    until chat.complete? || chat.waiting?
      chat.run_tools
      break if chat.waiting? || run.reload.completed?
      raise TurnLimitReached if chat.messages.where(role: "assistant").count >= run.agent_class::MAX_TURNS

      chat.generate
    end
  end

  def settle(run, chat)
    if chat.waiting?
      # Persisted tool call records: #tool_call_id is the provider's id that AskUserTool sees.
      chat.pending_approvals.each do |tool_call|
        question = run.questions.create_with(question: tool_call.arguments.with_indifferent_access[:question])
                      .find_or_create_by!(tool_call_id: tool_call.tool_call_id)
        run.log("question", "Asked: #{question.question}") if question.previously_new_record?
      end
      run.transition_to!(:waiting_for_user)
    elsif !run.completed?
      fail_run(run, "The agent stopped without finishing.")
    end
  end

  def fail_run(run, message)
    run.log("error", message)
    run.transition_to!(:failed, error_message: message)
  end
end
