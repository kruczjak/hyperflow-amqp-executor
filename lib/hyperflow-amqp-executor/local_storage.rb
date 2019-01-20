module Executor
  module LocalStorage
    def workdir
      yield (@job.options.workdir || '/workdir')
    end
  end
end

