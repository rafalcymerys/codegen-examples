require "open3"

class ExecuteRubyTool < RubyLLM::Tool
  TIMEOUT = 60.seconds
  MAX_OUTPUT = 12_000

  description "Executes Ruby code in a subprocess and returns its exit status and combined stdout/stderr " \
              "(truncated to #{MAX_OUTPUT} characters). The final result must be written to ENV['OUTPUT_FILE']. " \
              "The working directory is a scratch directory that persists between calls. " \
              "Scripts are killed after #{TIMEOUT.to_i} seconds."

  parameter :code, description: "The Ruby code to execute"

  def initialize(run)
    @run = run
  end

  def execute(code:)
    FileUtils.mkdir_p(@run.workdir)
    script = @run.workdir.join("script.rb")
    script.write(code)

    output, status, timed_out = run(script)
    @run.log("tool", timed_out ? "Ran Ruby code (timed out)" : "Ran Ruby code (exit status #{status})", "#{code}\n\n# => output\n#{output}")

    { exit_status: status, timed_out:, output: }
  rescue => e
    @run.log("error", "The Ruby code could not be executed", "#{e.class}: #{e.message}")
    { error: "The code could not be executed: #{e.class}: #{e.message}" }
  end

  private

  # The script gets a minimal environment, so secrets of the Rails process
  # (API keys, credentials) are not visible to the generated code.
  def environment
    { "PATH" => ENV["PATH"], "HOME" => ENV["HOME"], "LANG" => "en_US.UTF-8" }.merge(@run.script_environment)
  end

  def run(script)
    Open3.popen2e(environment, RbConfig.ruby, script.to_s,
                  chdir: @run.workdir.to_s, unsetenv_others: true, pgroup: true) do |stdin, out, thread|
      stdin.close
      reader = Thread.new { out.read }
      timed_out = thread.join(TIMEOUT).nil?
      Process.kill("KILL", -thread.pid) if timed_out

      output = reader.value.to_s.scrub
      output = "#{output.first(MAX_OUTPUT)}\n...[truncated, #{output.length} characters in total]" if output.length > MAX_OUTPUT
      [ output, thread.value.exitstatus, timed_out ]
    end
  end
end
