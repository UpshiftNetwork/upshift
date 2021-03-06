# frozen_string_literal: true

module VCS
  module Operations
    # Calculate and cache file diffs from one commit to another
    class FileDiffsCalculator
      # Initialize a new instance of FileDiffCalculator to calculate file diffs
      # between commit and its parent commit
      # TODO: Rename from commit & parent_commit to new and old
      def initialize(commit:, parent_commit: nil)
        self.commit = commit
        self.parent_commit = parent_commit || commit.parent
      end

      # Persist diffs to database in FileDiffs table
      def cache_diffs!
        VCS::FileDiff.import(diffs, validate: false)
      end

      def file_diffs
        diffs.map { |diff| VCS::FileDiff.new(diff) }
      end

      # Return diffs as attribute hashes
      def diffs
        @diffs ||= calculate_diffs
      end

      private

      attr_accessor :commit, :parent_commit

      # Number of ancestors to load for each diff
      def ancestor_depth
        3
      end

      # Return an array of ancestors names for a given diff, up to default depth
      def ancestors_names_for(diff)
        ancestry_tree.ancestors_names_for(diff['file_id'],
                                          depth: ancestor_depth)
      end

      # Return (or load) ancestry tree for diffs
      def ancestry_tree
        @ancestry_tree ||=
          FileAncestryTree.generate(
            commit: commit,
            parent_commit: parent_commit,
            file_ids: raw_diffs.map { |diff| diff['file_id'] },
            depth: ancestor_depth
          )
      end

      # Calculate diffs by converting raw diffs to attribute hashes and adding
      # ancestor names up to default depth
      def calculate_diffs
        raw_diffs.map do |raw_diff|
          raw_diff_to_diff(raw_diff)
            .merge('first_three_ancestors' => ancestors_names_for(raw_diff))
            .except('file_id')
        end
      end

      # Return committed files where version changed from commit parent to
      # commit
      def committed_files_where_version_changed
        VCS::CommittedFile
          .where_version_changed_between_commits(commit, parent_commit&.id)
      end

      # Parse a single raw diff to an attribute diff
      def raw_diff_to_diff(raw_diff)
        raw_diff
          .slice('file_id')
          .merge(
            'commit_id' => commit.id,
            'new_version_id' =>
              version_id_from_raw_diff(raw_diff, commit.id),
            'old_version_id' =>
              version_id_from_raw_diff(raw_diff, parent_commit&.id)
          )
      end

      # Return committed files where version changed from commit parent to
      # commit grouped into a single row for every file resource
      def raw_diffs
        @raw_diffs ||=
          VCS::FileDiff
          .select('file_id', 'json_agg(subquery) AS versions')
          .from(committed_files_where_version_changed)
          .group('file_id')
          .reorder('subquery.file_id')
          .map(&:attributes)
      end

      # Retrieve the file resource version from the given raw diff and commit
      def version_id_from_raw_diff(raw_diff, commit_id)
        raw_diff['versions']
          .find { |versions| versions['commit_id'] == commit_id }
          &.fetch('version_id', nil)
          &.to_i
      end
    end
  end
end
