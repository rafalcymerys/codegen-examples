class QuestionsController < ApplicationController
  def answer
    question = AgentQuestion.find(params[:id])
    run = question.subject
    answer = params[:answer].to_s.strip

    if answer.present? && !question.answered?
      question.update!(answer:, answered_at: Time.current)
      run.log("answer", "You answered: #{answer}")

      if run.questions.unanswered.none?
        run.transition_to!(:processing)
        AgentRunJob.perform_later(run)
      else
        run.broadcast_state
      end
    end

    redirect_to run_location(run)
  end

  private

  def run_location(run)
    case run
    when BreedImport then cat_import_breeds_path(run.cat_import)
    when BreedAssignment then cat_import_breed_assignments_path(run.cat_import)
    else run
    end
  end
end
