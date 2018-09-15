
class ExternalSheller

  def initialize(_parent)
  end

  def cd_exec(path, *commands)
    # the [[ -d ]] is to avoid spurious [cd path] failure
    # output when the tests are running
    output, exit_status = exec(["[[ -d #{path} ]]", "cd #{path}"] + commands)
    [output, exit_status]
  end

  def exec(*commands)
    command = commands.join(' && ')
    output = `#{command}`
    exit_status = $?.exitstatus
    [output, exit_status]
  end

end
