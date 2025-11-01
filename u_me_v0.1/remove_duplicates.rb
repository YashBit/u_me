#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('u_me_v0.1.xcodeproj')
target = project.targets.first

# Find and remove duplicate file references
files_seen = {}
files_to_remove = []

project.files.each do |file|
  if file.path
    if files_seen[file.path]
      puts "Found duplicate: #{file.path}"
      files_to_remove << file
    else
      files_seen[file.path] = file
    end
  end
end

# Remove duplicates from project
files_to_remove.each do |file|
  file.remove_from_project
  puts "Removed duplicate reference: #{file.path}"
end

# Remove duplicate build files
build_files_seen = {}
build_files_to_remove = []

target.source_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path
    path = build_file.file_ref.path
    if build_files_seen[path]
      build_files_to_remove << build_file
      puts "Duplicate in build phase: #{path}"
    else
      build_files_seen[path] = true
    end
  end
end

build_files_to_remove.each do |build_file|
  target.source_build_phase.remove_build_file(build_file)
  puts "Removed from build phase: #{build_file.file_ref.path}"
end

project.save
puts "Cleaned up duplicates!"
