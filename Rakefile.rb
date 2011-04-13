# Originally adopted from Tate Johnson's Rakefile
# http://github.com/tatey/tatey.com/blob/master/Rakefile
# Some code from the jekyll executable file
# http://github.com/mojombo/jekyll/blob/master/bin/jekyll

require 'webrick'
require 'directory_watcher'
require "term/ansicolor"
require "jekyll"
include Term::ANSIColor
include WEBrick

task :default => :develop
 
desc 'Build site with Jekyll.'
task :build do
	buildSite()
end

def buildSite(mode = "development")
	printHeader "Compiling website..."
	options = Jekyll.configuration({ "mode" => mode })
	options["pygments"] = false if mode == "development"
	@site = Jekyll::Site.new(options)
	@site.process
end
 
def globs(source)
	Dir.chdir(source) do
		dirs = Dir['*'].select { |x| File.directory?(x) }
		dirs -= ['_site']
		dirs = dirs.map { |x| "#{x}/**/*" }
		dirs += ['*']
	end
end

desc 'Enter development mode.'
task :develop => :build do
	printHeader "Auto-regenerating enabled."
	directoryWatcher = DirectoryWatcher.new("./")
	directoryWatcher.interval = 1
	directoryWatcher.glob = globs(Dir.pwd)
	directoryWatcher.add_observer do |*args| @site.process end
	directoryWatcher.start
	mimeTypes = WEBrick::HTTPUtils::DefaultMimeTypes
	mimeTypes.store 'js', 'application/javascript'
	server = HTTPServer.new(
		:BindAddress	=> "localhost",
		:Port			=> 4000,
		:DocumentRoot	=> "_site",
		:MimeTypes		=> mimeTypes,
		:Logger			=> Log.new($stderr, Log::ERROR),
		:AccessLog		=> [["/dev/null", AccessLog::COMBINED_LOG_FORMAT ]]
	)
	thread = Thread.new { server.start }
	trap("INT") { server.shutdown }
	printHeader "Development server started at http://localhost:4000/"
	printHeader "Opening website in default web browser..."
	%x[open http://localhost:4000/]
	printHeader "Development mode entered."
	thread.join()
end

desc 'Remove all built files.'
task :clean do
	printHeader "Cleaning build directory..."
	%x[rm -rf _site]
end

desc 'Build, deploy, then clean.'
task :deploy do
	buildSite("deployment")
	printHeader "Deploying website to http://georgews.com/"
	sh 'rsync -rtzh _site/ georgews@zcr.me:~/sites/georgews.com/public/'
	Rake::Task['clean'].execute
end

task :new do
	title = ask("Title: ")
	fileName = ask("Filename: ")
	article = {"title" => title, "layout" => "post"}.to_yaml
	article << "---"
	path = "_posts/#{Time.now.strftime("%Y-%m-%d")}#{'-' + fileName}.md"
	unless File.exist?(path)
		File.open(path, "w") do |file| 
			file.write article
			sh "mate " + path
		end
    	puts "A new article was created at #{path}."
	else
    	puts "There was an error creating the article, #{path} already exists."
	end
end

def ask message
	print message
	STDIN.gets.chomp
end

def printHeader headerText
	print bold + blue + "==> " + reset
	print bold + headerText + reset + "\n"
end