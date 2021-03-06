# frozen_string_literal: true

# Define helpers needed for file restoration
module FileRestoresHelper
  def restorable?(diff, branch)
    return false unless diff.new_version.present?

    VCS::Operations::FileRestore
      .new(version: diff.new_version, target_branch: branch)
      .restorable?
  end

  def restore_action_path(project, diff)
    return nil unless restorable?(diff, project.master_branch)

    profile_project_file_restores_path(
      project.owner, project, diff.new_version
    )
  end
end
