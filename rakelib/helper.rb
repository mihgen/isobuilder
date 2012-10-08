require 'open-uri'

def with(value)
  yield(value)
end

# copy_files 'articles/*.gif', 'articles', :articles
def copy_files(srcGlob, targetDir, taskSymbol)
  mkdir_p targetDir
  FileList[srcGlob].each do |f|
    target = File.join targetDir, File.basename(f)
    file target => [f] do |t|
      cp f, target
    end
    task taskSymbol => target
  end
end

def download_from_url(url, target_file, task_symbol)
  directory File.dirname(target_file)
  file target_file => File.dirname(target_file) do
    puts "Downloading from url: #{url}"
    open("#{target_file}.tmp", 'wb') do |file|
      file << open(url).read
    end
    mv "#{target_file}.tmp", target_file
  end
  task task_symbol => target_file
end

# Usage md5file(file, task_which_requires_this, task_to_call_if_chksum_doesn't_match)
def md5file(file, task_ext, task_dep)
  task :this_task do
    if File.exists?("#{file}.tmp")
      old_sum = File.read("#{file}.tmp").chomp
    else
      old_sum = ""
    end
    new_sum = `md5sum #{file}`.chomp
    if old_sum != new_sum
      Rake::Task[task_dep].invoke
      File.open("#{file}.tmp", "w") {|f| f.write(new_sum)}
    end
  end
  task task_ext => :this_task 
end
