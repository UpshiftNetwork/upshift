# frozen_string_literal: true

require 'models/shared_examples/vcs/having_remote.rb'

RSpec.describe VCS::FileBackup, type: :model do
  subject(:backup) { build_stubbed :vcs_file_backup }

  it_should_behave_like 'vcs: having remote' do
    let(:object) { build :vcs_file_backup }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:file_version).dependent(false) }
  end

  describe 'validations' do
    subject(:backup) { build :vcs_file_backup }

    it do
      is_expected
        .to validate_presence_of(:file_version_id).with_message('must exist')
    end
    it { is_expected.to validate_presence_of(:remote_file_id) }
  end
end
