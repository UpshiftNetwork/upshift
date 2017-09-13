# frozen_string_literal: true

RSpec.describe 'files/edit_content', type: :view do
  let(:project) { create(:project) }
  let(:file)    { create(:vc_file, collection: project.files) }

  before do
    assign(:project, project)
    assign(:file, file)
    assign(:file_action, :edit)
  end

  it 'renders a form with edit_profile_project_file_path action' do
    edit_path = edit_profile_project_file_path project.owner, project, file
    render
    expect(rendered).to have_css(
      'form'\
      "[action='#{edit_path}']"\
      "[method='post']"
    )
  end

  it 'uses method :patch' do
    render
    expect(rendered)
      .to have_css("input[name='_method'][value='patch']", visible: false)
  end

  it 'renders errors' do
    file.errors.add(:base, 'mock error')
    render
    expect(rendered).to have_css '.validation-errors', text: 'mock error'
  end

  it 'has an input field for content' do
    render
    expect(rendered).to have_css 'textarea#version_control_file_content'
  end

  it 'has an input field for revision summary' do
    render
    expect(rendered).to have_css 'input#version_control_file_revision_summary'
  end

  it 'has a button to save the file' do
    render
    expect(rendered).to have_css "button[action='submit']", text: 'Save'
  end
end
