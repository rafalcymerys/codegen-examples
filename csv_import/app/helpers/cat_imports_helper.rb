module CatImportsHelper
  STATUS_LABELS = {
    "pending" => "Queued",
    "processing" => "Agent is working",
    "waiting_for_user" => "Waiting for your answer",
    "completed" => "Completed",
    "failed" => "Failed"
  }.freeze

  def status_badge(run)
    tag.span STATUS_LABELS.fetch(run.status), class: "badge badge-#{run.status.dasherize}"
  end
end
