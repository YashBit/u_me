#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('u_me_v0.1.xcodeproj')
target = project.targets.first

puts "Cleaning up duplicate references..."

# Track files we've seen
seen_paths = {}
removed_count = 0

# Remove duplicate file references
target.source_build_phase.files.reverse.each do |build_file|
  if build_file.file_ref
    path = build_file.file_ref.path
    
    if path && (path.include?("AuthViewModel.swift") || path.include?("LoginView.swift"))
      if seen_paths[path]
        puts "Removing duplicate: #{path}"
        target.source_build_phase.remove_build_file(build_file)
        removed_count += 1
      else
        seen_paths[path] = true
        puts "Keeping: #{path}"
      end
    end
  end
end

puts "Removed #{removed_count} duplicate references"
project.save
puts "Project saved!"
