# frozen_string_literal: true

module Providers
  module GoogleDrive
    # Parser for various GoogleDrive-supported mime types
    class MimeType
      # TODO: Add word document formats: word_docx, word_doc, open_document_text
      MIME_TYPES = {
        document: 'application/vnd.google-apps.document',
        drawing: 'application/vnd.google-apps.drawing',
        folder: 'application/vnd.google-apps.folder',
        form: 'application/vnd.google-apps.form',
        other: 'other',
        pdf: 'application/pdf',
        presentation: 'application/vnd.google-apps.presentation',
        spreadsheet: 'application/vnd.google-apps.spreadsheet',
        word_docx: 'application/vnd.openxmlformats-officedocument' \
                   '.wordprocessingml.document',
        word_doc: 'application/msword',
        open_document_text: 'application/vnd.oasis.opendocument.text'
      }.freeze

      # TODO: Reference word document formats
      EXPORT_FORMATS = {
        document: 'application/vnd.openxmlformats-officedocument'\
                  '.wordprocessingml.document',
        spreadsheet: 'application/vnd.openxmlformats-officedocument'\
                     '.spreadsheetml.sheet',
        drawing: 'image/png',
        presentation: 'application/vnd.openxmlformats-officedocument'\
                      '.presentationml.presentation'
      }.freeze

      # The mime types that represent texts
      TEXT_TYPES = %i[document pdf word_docx word_doc open_document_text].freeze

      class << self
        # Define getters such as .document, .folder, and .spreadsheet
        MIME_TYPES.each do |type, mime_type|
          define_method(type) do
            mime_type
          end
        end

        # Define type checkers such as .document?, .folder?, and .spreadsheet?
        MIME_TYPES.each do |type, mime_type|
          define_method("#{type}?") do |type_to_check|
            type_to_check == mime_type
          end
        end

        # Define symbolizer that returns :document, :folder, etc...
        # Return :other if not found
        def to_symbol(mime_type)
          MIME_TYPES.key(mime_type) || :other
        end
      end

      attr_accessor :type

      def initialize(type)
        self.type = type
      end

      def exportable?
        EXPORT_FORMATS.key?(to_sym)
      end

      def export_as
        EXPORT_FORMATS[to_sym]
      end

      def text_type?
        TEXT_TYPES.include? to_sym
      end

      def to_sym
        self.class.to_symbol(type)
      end
    end
  end
end
