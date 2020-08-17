# Inspiration:
#https://github.com/newrelic/rpm/blob/2bc79e102185861ff078fd15ccbf31a32f088b8a/lib/new_relic/agent/samplers/memory_sampler.rb

class Delayed::MemorySampler

  # Returns the amount of resident memory this process is using in MB
  def get_memory
    proc_status = File.open(proc_status_file, "r") {|f| f.read_nonblock(4096).strip }
    if proc_status =~ /RSS:\s*(\d+) kB/i
      return $1.to_f / 1024.0
    end
    raise "Unable to find RSS in #{proc_status_file}"
  end

  def proc_status_file
    "/proc/#{$$}/status"
  end

  def to_s
    "proc status file sampler: #{proc_status_file}"
  end

  def linux?
    (RUBY_PLATFORM =~ /linux/).present?
  end
end
