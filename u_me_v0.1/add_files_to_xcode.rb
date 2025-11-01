#!/usr/bin/env ruby
require 'xcodeproj'

# Open the project
project_path = 'u_me_v0.1.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get main target
target = project.targets.first

# Get main group
main_group = project.main_group

# Function to add files recursively
def add_files_to_group(group, dir_path, target)
  Dir.glob("#{dir_path}/**/*.swift").each do |file_path|
    unless group.find_file_by_path(file_path)
      file_ref = group.new_file(file_path)
      target.source_build_phase.add_file_reference(file_ref)
      puts "Added: #{file_path}"
    end
  end
end

# Add Authentication files
auth_group = main_group.find_subpath('Sources/Features/Authentication')
add_files_to_group(auth_group, 'Sources/Features/Authentication', target)

# Add Platform files
platform_group = main_group.find_subpath('Sources/Platform')
add_files_to_group(platform_group, 'Sources/Platform/Apple', target)

# Add Core files
core_group = main_group.find_subpath('Sources/Core')
add_files_to_group(core_group, 'Sources/Core/Data/Local/Keychain', target)

# Add Infrastructure files
infra_group = main_group.find_subpath('Sources/Infrastructure')
add_files_to_group(infra_group, 'Sources/Infrastructure/DI', target)

# Save the project
project.save
puts "Project updated successfully!"
