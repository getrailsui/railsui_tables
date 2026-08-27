# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new("test:ruby") do |task|
  task.libs << "lib" << "test"
  task.test_files = FileList["test/**/*_test.rb"]
end

task "test:js" do
  abort "JavaScript tests failed" unless system("node --import ./test/javascript/stubs.mjs --test test/javascript/*.test.mjs")
end

task test: ["test:ruby", "test:js"]
