# frozen_string_literal: true

# Controller for project revisions
class RevisionsController < ApplicationController
  include ProjectLockable

  # Execute without lock or render/redirect delay
  before_action :authenticate_account!
  before_action :set_project
  before_action :authorize_action

  around_action :wrap_action_in_project_lock

  # Execute with lock and render/redirect delay
  before_action :build_revision
  before_action :set_file_diffs, only: :new
  before_action :set_root_folder

  def new; end

  def create
    if @revision.commit(revision_params[:title], revision_params[:summary],
                        revision_author)
      redirect_with_success_to(
        profile_project_root_folder_path(@project.owner, @project)
      )
    else
      set_file_diffs
      render :new
    end
  end

  private

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to [@project.owner, @project], alert: exception.message
  end

  def authorize_action
    authorize! params[:action].to_sym, :revision, @project
  end

  def build_revision
    tree_id = revision_params[:tree_id] if params[:revision]
    @revision = @project.repository.build_revision(tree_id)
  end

  def revision_author
    # current_user.to_revision_author
    { name: current_user.handle, email: current_user.id.to_s }
  end

  # TODO@performance: Improve N+1 query by bulk preloading ancestors
  def set_ancestors_of_file_diffs
    @ancestors_of_file_diffs =
      @file_diffs.index_by(&:id).transform_values!(&:ancestors_of_file)
  end

  def set_file_diffs
    @file_diffs = @revision.diff(@project.repository.revisions.last)
                           .changed_files_as_diffs

    _filter_out_unchanged_file_diffs
    set_ancestors_of_file_diffs

    helpers.sort_file_diffs!(@file_diffs)
  end

  def set_project
    @project = Project.find(params[:profile_handle], params[:project_slug])
  end

  def set_root_folder
    @root_folder = @project.files.root
  end

  def revision_params
    params.require(:revision).permit(:title, :summary, :tree_id)
  end

  # TODO@refactor: This should not be the controller's responsibility. Ideally,
  # =>             take care of this at source (i.e.:
  # =>             VersionControl::RevisionDiff#_rugged_deltas)
  def _filter_out_unchanged_file_diffs
    @file_diffs.select!(&:changed?)
  end
end
